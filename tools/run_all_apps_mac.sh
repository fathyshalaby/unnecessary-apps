#!/usr/bin/env zsh
# Build and UI-test all 44 active apps on Mac.
# Requires Xcode at /Applications/Xcode.app

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
DEST="${SIMULATOR_DEST:-platform=iOS Simulator,name=iPhone 16e,OS=latest}"
PROJECT="UnnecessaryApps.xcodeproj"
SCHEME="${UI_TEST_SCHEME:-App03DoNotTextThemUITests}"

if [[ ! -d "$DEVELOPER_DIR" ]]; then
  echo "error: Xcode not found at $DEVELOPER_DIR" >&2
  exit 1
fi

echo "== Repo checks =="
python3 tools/generate_app_manifest.py
python3 tools/audit_launch_readiness.py
python3 tools/validate_store_metadata.py
python3 tools/generate_xcode_project.py
python3 tools/generate_demo_scripts.py

echo "== Build all app targets (via $SCHEME dependencies) =="
xcodebuild build \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "$DEST" \
  -quiet

echo "== Run full UI suite (47 journeys, 44 apps) =="
xcodebuild test \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "$DEST"

echo "all-apps Mac verification complete"
