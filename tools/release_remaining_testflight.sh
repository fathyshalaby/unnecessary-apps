#!/bin/zsh

set -euo pipefail

# Orchestrate the 39 apps that do not yet have a processed TestFlight build.
# The underlying release script still owns signing, upload, metadata, and
# group assignment. Each invocation gets its own run ID so an interrupted
# batch cannot be overwritten accidentally.

script_dir="${0:A:h}"
release_script="$script_dir/release_all_testflight.sh"
base_run_id="${TESTFLIGHT_RUN_ID:-$(date +%Y%m%d-%H%M%S)-remaining-39}"
run_app40_canary="${RELEASE_RUN_APP40_CANARY:-true}"

if [[ ! -x "$release_script" ]]; then
  echo "Missing executable release helper: $release_script" >&2
  exit 1
fi

case "$run_app40_canary" in
  true|false) ;;
  *)
    echo "RELEASE_RUN_APP40_CANARY must be true or false." >&2
    exit 1
    ;;
esac

if [[ "$run_app40_canary" == "true" ]]; then
  echo "Running App40 HealthKit signing canary."
  TESTFLIGHT_RUN_ID="${base_run_id}-app40" \
  RELEASE_APP_NUMBERS=40 \
  "$release_script"
fi

typeset -a batch_specs
batch_specs=(
  "1-2,4-10"
  "11-23"
  "25-35"
  "38,41-44"
)

batch_index=1
for batch_spec in "${batch_specs[@]}"; do
  echo "Running remaining batch ${batch_index}/4: ${batch_spec}"
  TESTFLIGHT_RUN_ID="${base_run_id}-batch-${batch_index}" \
  RELEASE_APP_NUMBERS="$batch_spec" \
  "$release_script"
  batch_index=$((batch_index + 1))
done

echo "Remaining 39-app TestFlight release lane complete."
