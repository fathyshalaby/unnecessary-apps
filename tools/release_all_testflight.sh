#!/bin/zsh

set -euo pipefail

project_path="${PROJECT_PATH:-UnnecessaryApps.xcodeproj}"
export_options="${EXPORT_OPTIONS:-release/ExportOptions-TestFlight.plist}"
team_id="${DEVELOPMENT_TEAM:-2CGZC35S8K}"
signing_identity="${CODE_SIGN_IDENTITY:-Apple Distribution}"
signing_profiles_file="${SIGNING_PROFILES_FILE:-$HOME/.private_keys/unnecessary-apps-profiles.json}"
asc_env_file="${ASC_ENV_FILE:-$HOME/.private_keys/appstoreconnect.env}"
auth_mode="${TESTFLIGHT_AUTH_MODE:-api}"
run_id="${TESTFLIGHT_RUN_ID:-$(date +%Y%m%d-%H%M%S)}"
run_root="${TESTFLIGHT_OUTPUT_DIR:-build/testflight-runs}/$run_id"
derived_data="$run_root/DerivedData"
manifest="$run_root/manifest.tsv"
status_file="$run_root/status.tsv"
notes_helper="${TESTFLIGHT_NOTES_HELPER:-$HOME/.codex/plugins/cache/openai-curated-remote/codex-testflight-release/0.1.1/skills/codex-ios-api-build/scripts/set_testflight_whats_new.js}"
selected_numbers=(${(s:,:)${RELEASE_APP_NUMBERS:-}})
if (( ${#selected_numbers[@]} > 0 )); then
  typeset -a expanded_numbers
  expanded_numbers=()
  for selection in "${selected_numbers[@]}"; do
    if [[ "$selection" == *-* ]]; then
      range_start="${selection%%-*}"
      range_end="${selection##*-}"
      if [[ "$range_start" == <-> && "$range_end" == <-> && range_start -le range_end ]]; then
        for ((number = range_start; number <= range_end; number++)); do
          expanded_numbers+=("$number")
        done
        continue
      fi
    fi
    expanded_numbers+=("$selection")
  done
  selected_numbers=("${expanded_numbers[@]}")
fi

if [[ ! -f "$signing_profiles_file" ]]; then
  echo "Missing signing profile manifest: $signing_profiles_file" >&2
  echo "Generate App Store provisioning profiles before running a release." >&2
  exit 1
fi

typeset -A signing_profile_names
while IFS=$'\t' read -r profile_number profile_name; do
  [[ -n "$profile_number" && -n "$profile_name" ]] || continue
  signing_profile_names[$profile_number]="$profile_name"
done < <(python3 - "$signing_profiles_file" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    profiles = json.load(handle)

for number, profile in sorted(profiles.items(), key=lambda item: int(item[0])):
    print(f"{number}\t{profile['profileName']}")
PY
)

mkdir -p "$run_root" "$derived_data"

python3 tools/validate_store_metadata.py
python3 tools/prepare_testflight_manifest.py \
  --require-app-records \
  --app-numbers "${RELEASE_APP_NUMBERS:-}" \
  --output "$manifest"

auth_args=()
if [[ "$auth_mode" == "api" ]]; then
  if [[ ! -f "$asc_env_file" ]]; then
    echo "Missing App Store Connect credentials: $asc_env_file" >&2
    exit 1
  fi

  set -a
  # shellcheck disable=SC1090
  . "$asc_env_file"
  set +a

  for required_name in ASC_KEY_ID ASC_ISSUER_ID ASC_KEY_PATH; do
    if [[ -z "${(P)required_name:-}" ]]; then
      echo "Missing $required_name in $asc_env_file" >&2
      exit 1
    fi
  done

  if [[ ! -f "$ASC_KEY_PATH" ]]; then
    echo "ASC_KEY_PATH does not exist." >&2
    exit 1
  fi
  if [[ ! -f "$notes_helper" ]]; then
    echo "Missing TestFlight notes helper: $notes_helper" >&2
    exit 1
  fi
  beta_group_name="${ASC_BETA_GROUP:-Unnecessary Apps Friends}"
  submit_beta_review="${ASC_SUBMIT_BETA_REVIEW:-false}"
  if [[ "$submit_beta_review" == "true" ]]; then
    missing_review_contact=()
    [[ -n "${ASC_REVIEW_CONTACT_FIRST_NAME:-}" ]] || missing_review_contact+=(ASC_REVIEW_CONTACT_FIRST_NAME)
    [[ -n "${ASC_REVIEW_CONTACT_LAST_NAME:-}" ]] || missing_review_contact+=(ASC_REVIEW_CONTACT_LAST_NAME)
    [[ -n "${ASC_REVIEW_CONTACT_PHONE:-}" ]] || missing_review_contact+=(ASC_REVIEW_CONTACT_PHONE)
    [[ -n "${ASC_REVIEW_CONTACT_EMAIL:-}" || -n "${ASC_FEEDBACK_EMAIL:-}" ]] || missing_review_contact+=(ASC_REVIEW_CONTACT_EMAIL)
    if (( ${#missing_review_contact[@]} > 0 )); then
      echo "ASC_SUBMIT_BETA_REVIEW=true requires: ${missing_review_contact[*]}" >&2
      echo "Set the reviewer contact fields before starting the signed release." >&2
      exit 1
    fi
  fi
  if [[ "$submit_beta_review" == "true" || -n "${ASC_REVIEW_CONTACT_FIRST_NAME:-}" || -n "${ASC_REVIEW_CONTACT_LAST_NAME:-}" || -n "${ASC_REVIEW_CONTACT_PHONE:-}" || -n "${ASC_REVIEW_CONTACT_EMAIL:-}" ]]; then
    ASC_ENV_FILE="$asc_env_file" node tools/sync_testflight_beta_metadata.js \
      --app-numbers="${RELEASE_APP_NUMBERS:-}"
  fi
  auth_args=(
    -authenticationKeyPath "$ASC_KEY_PATH"
    -authenticationKeyID "$ASC_KEY_ID"
    -authenticationKeyIssuerID "$ASC_ISSUER_ID"
  )
elif [[ "$auth_mode" != "xcode-account" ]]; then
  echo "TESTFLIGHT_AUTH_MODE must be api or xcode-account." >&2
  exit 1
fi

if [[ ! -f "$status_file" ]]; then
  print -r -- $'number\tscheme\tbuild\tstage\tupdated_at' > "$status_file"
fi

is_selected() {
  local number="$1"
  if (( ${#selected_numbers[@]} == 0 )); then
    return 0
  fi
  local candidate
  for candidate in "${selected_numbers[@]}"; do
    [[ "$candidate" == "$number" ]] && return 0
  done
  return 1
}

record_status() {
  local number="$1" scheme="$2" build="$3" stage="$4"
  print -r -- "$number"$'\t'"$scheme"$'\t'"$build"$'\t'"$stage"$'\t'"$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$status_file"
}

tail -n +2 "$manifest" | while IFS=$'\t' read -r number scheme folder bundle_id build_number app_store_id name note64; do
  is_selected "$number" || continue

  app_root="$run_root/$scheme-build-$build_number"
  archive_path="$app_root/$scheme.xcarchive"
  export_path="$app_root/export"
  archive_log="$app_root/archive.log"
  upload_log="$app_root/upload.log"
  mkdir -p "$app_root"

  if [[ -d "$archive_path" || -d "$export_path" ]]; then
    echo "Refusing to overwrite existing output for $scheme at $app_root" >&2
    echo "Choose a new TESTFLIGHT_RUN_ID or inspect the existing run." >&2
    exit 1
  fi

  echo "[$number/44] Archiving $name as build $build_number"
  record_status "$number" "$scheme" "$build_number" "archiving"

  signing_profile="${signing_profile_names[$number]:-}"
  if [[ -z "$signing_profile" ]]; then
    echo "No App Store provisioning profile is configured for app $number ($bundle_id)." >&2
    exit 1
  fi

  signing_args=(
    CODE_SIGN_STYLE=Manual
    "CODE_SIGN_IDENTITY=$signing_identity"
  )
  if [[ "$number" != "13" ]]; then
    signing_args+=("PROVISIONING_PROFILE_SPECIFIER=$signing_profile")
  fi

  DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild archive \
    -project "$project_path" \
    -scheme "$scheme" \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    -archivePath "$archive_path" \
    -derivedDataPath "$derived_data" \
    -clonedSourcePackagesDirPath "$derived_data/SourcePackages" \
    -disableAutomaticPackageResolution \
    -allowProvisioningUpdates \
    "${auth_args[@]}" \
    "CURRENT_PROJECT_VERSION=$build_number" \
    "DEVELOPMENT_TEAM=$team_id" \
    "${signing_args[@]}" \
    > "$archive_log" 2>&1

  product_app=$(find "$archive_path/Products/Applications" -maxdepth 1 -type d -name '*.app' -print -quit)
  if [[ -z "$product_app" ]]; then
    echo "No app product found in $archive_path" >&2
    exit 1
  fi

  actual_bundle=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$product_app/Info.plist")
  actual_build=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$product_app/Info.plist")
  encryption=$(/usr/libexec/PlistBuddy -c 'Print :ITSAppUsesNonExemptEncryption' "$product_app/Info.plist")
  [[ "$actual_bundle" == "$bundle_id" ]] || { echo "Bundle mismatch for $scheme" >&2; exit 1; }
  [[ "$actual_build" == "$build_number" ]] || { echo "Build mismatch for $scheme" >&2; exit 1; }
  [[ "$encryption" == "false" ]] || { echo "Encryption flag mismatch for $scheme" >&2; exit 1; }
  codesign --verify --deep --strict "$product_app"
  security cms -D -i "$product_app/embedded.mobileprovision" >/dev/null
  record_status "$number" "$scheme" "$build_number" "archive-verified"

  echo "[$number/44] Uploading $name build $build_number"
  xcodebuild -exportArchive \
    -archivePath "$archive_path" \
    -exportOptionsPlist "$export_options" \
    -exportPath "$export_path" \
    -allowProvisioningUpdates \
    "${auth_args[@]}" \
    > "$upload_log" 2>&1
  record_status "$number" "$scheme" "$build_number" "uploaded"

  if [[ "$auth_mode" == "api" ]]; then
    what_to_test=$(print -rn -- "$note64" | base64 --decode)
    ASC_ENV_FILE="$asc_env_file" \
    ASC_BETA_GROUP="$beta_group_name" \
    ASC_SUBMIT_BETA_REVIEW="$submit_beta_review" \
    node "$notes_helper" \
      "$bundle_id" "$build_number" en-US "$what_to_test"
    record_status "$number" "$scheme" "$build_number" "notes-set"
    record_status "$number" "$scheme" "$build_number" "external-group-assigned"
  else
    echo "Uploaded with the signed-in Xcode account; What to Test remains a manual/API follow-up."
    record_status "$number" "$scheme" "$build_number" "notes-pending"
  fi
done

echo "TestFlight run complete. Status: $status_file"
