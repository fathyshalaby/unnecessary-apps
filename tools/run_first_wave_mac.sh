#!/usr/bin/env zsh
# Build and UI-test the first ten release-lane apps on Mac.
# Requires Xcode at /Applications/Xcode.app

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
DEST="${SIMULATOR_DEST:-platform=iOS Simulator,name=iPhone 16e,OS=latest}"
PROJECT="UnnecessaryApps.xcodeproj"

if [[ ! -d "$DEVELOPER_DIR" ]]; then
  echo "error: Xcode not found at $DEVELOPER_DIR" >&2
  echo "Set DEVELOPER_DIR to your Xcode.app/Contents/Developer path." >&2
  exit 1
fi

echo "== Repo checks =="
python3 tools/audit_first_wave.py
python3 tools/validate_store_metadata.py
python3 tools/generate_xcode_project.py

FIRST_WAVE_SCHEMES=(
  App20RealEmail
  App03DoNotTextThem
  App10WhatWasIDoing
  App18TinyGratitude
  App28OverthinkingBoard
  App43HydrationNarc
  App13ToiletTimer
  App17MeetingBingo
  App22SnackRoulette
  App11AmIEarly
)

echo "== Build first-wave app targets =="
for scheme in "${FIRST_WAVE_SCHEMES[@]}"; do
  echo "building $scheme..."
  xcodebuild build \
    -project "$PROJECT" \
    -scheme "$scheme" \
    -destination "$DEST" \
    -quiet
done

echo "== Run FirstWaveUITests (10 journeys) =="
xcodebuild test \
  -project "$PROJECT" \
  -scheme FirstWaveUITests \
  -destination "$DEST"

echo "first-wave Mac verification complete"
