#!/bin/zsh

set -euo pipefail

project_path="UnnecessaryApps.xcodeproj"
output_dir="${ARCHIVE_OUTPUT_DIR:-build/local-archives}"
derived_data_path="$output_dir/DerivedData"
manifest_path="$output_dir/archive-manifest.tsv"
signing_allowed="${ARCHIVE_CODE_SIGNING_ALLOWED:-NO}"
signing_required="${ARCHIVE_CODE_SIGNING_REQUIRED:-NO}"
development_team="${ARCHIVE_DEVELOPMENT_TEAM:-}"

schemes=(
  App01ChairFinder
  App02BathroomMap
  App03DoNotTextThem
  App04SocialBatteryReceipt
  App05FridgeWitness
  App06ReceiptEmotionalDamage
  App07SockTribunal
  App08PlantCourt
  App09LaundryMountain
  App10WhatWasIDoing
  App11AmIEarly
  App12PigeonOrSeagull
  App13ToiletTimer
  App14OneMoreEpisode
  App15CanIWearThisAgain
  App16MicrowaveSommelier
  App17MeetingBingo
  App18TinyGratitude
  App19MedievalAdvice
  App20RealEmail
  App21VibeMeter
  App22SnackRoulette
  App23QuietCafe
  App24DogNameGuesser
  App25WaitingRoom
  App26NeighborNoise
  App27TinyMuseum
  App28OverthinkingBoard
  App29BenchReviews
  App30ApologyDraft
  App31HumanGPS
  App32LastSlice
  App33QueuePersonality
  App34WeatherOutfit
  App35DoorWasPush
  App36StepDebt
  App37SleepAlibi
  App38HeartRateEmail
  App39WorkoutExcuse
  App40HealthHoroscope
  App41RecoveryGoblin
  App42WalkingMeeting
  App43HydrationNarc
  App44RestDayPolice
)

mkdir -p "$output_dir"
rm -f "$manifest_path"

echo "Archive mode: signing allowed=$signing_allowed required=$signing_required"

signing_overrides=()
if [[ -n "$development_team" ]]; then
  signing_overrides+=("DEVELOPMENT_TEAM=$development_team")
fi

for scheme in "${schemes[@]}"; do
  archive_path="$output_dir/$scheme.xcarchive"
  log_path="$output_dir/$scheme.log"
  if [[ "${REUSE_EXISTING_ARCHIVES:-0}" == "1" && -d "$archive_path" ]]; then
    echo "Reusing $scheme"
  else
    echo "Archiving $scheme"
    DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild archive \
      -quiet \
      -project "$project_path" \
      -scheme "$scheme" \
      -configuration Release \
      -destination 'generic/platform=iOS' \
      -archivePath "$archive_path" \
      -derivedDataPath "$derived_data_path" \
      -clonedSourcePackagesDirPath "$derived_data_path/SourcePackages" \
      -disableAutomaticPackageResolution \
      CODE_SIGNING_ALLOWED="$signing_allowed" \
      CODE_SIGNING_REQUIRED="$signing_required" \
      "${signing_overrides[@]}" \
      > "$log_path" 2>&1
  fi
  test -d "$archive_path"
  product_app=$(find "$archive_path/Products/Applications" -maxdepth 1 -type d -name '*.app' -print -quit)
  archive_version=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$product_app/Info.plist")
  archive_build=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$product_app/Info.plist")
  printf '%s\t%s\t%s\n' "$scheme" "$archive_version" "$archive_build" >> "$manifest_path"
  echo "Archived $scheme"
done

echo "Archived ${#schemes[@]} local apps"
