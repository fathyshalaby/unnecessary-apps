#!/usr/bin/env zsh
# Capture App Store screenshots for the first ten release-lane apps.
# Run on Mac after a successful first-wave build.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
DEVICE_NAME="${SIMULATOR_DEVICE:-iPhone 16e}"
RAW_DIR="docs/screenshots/first-wave/raw"
OUT_DIR="release/screenshots/first-wave/iphone-6.9"

python3 tools/generate_app_manifest.py
python3 tools/generate_xcode_project.py
mkdir -p "$RAW_DIR" "$OUT_DIR"

# scheme:bundle_id:output_slug
APPS=(
  "App20RealEmail:corp.unecessary.app20realemail:real-email"
  "App03DoNotTextThem:corp.unecessary.app03donottextthem:do-not-text"
  "App10WhatWasIDoing:corp.unecessary.app10whatwasidoing:what-was-i-doing"
  "App18TinyGratitude:corp.unecessary.app18tinygratitude:tiny-gratitude"
  "App28OverthinkingBoard:corp.unecessary.app28overthinkingboard:overthinking"
  "App43HydrationNarc:corp.unecessary.app43hydrationnarc:hydration-narc"
  "App13ToiletTimer:corp.unecessary.app13toilettimer:toilet-timer"
  "App17MeetingBingo:corp.unecessary.app17meetingbingo:meeting-bingo"
  "App22SnackRoulette:corp.unecessary.app22snackroulette:snack-roulette"
  "App11AmIEarly:corp.unecessary.app11amiearly:am-i-early"
)

UDID="$(xcrun simctl list devices available "$DEVICE_NAME" | grep -Eo '[0-9A-F-]{36}' | head -1)"
if [[ -z "$UDID" ]]; then
  echo "error: no available simulator named $DEVICE_NAME" >&2
  exit 1
fi

xcrun simctl boot "$UDID" 2>/dev/null || true
open -a Simulator --args -CurrentDeviceUDID "$UDID"

echo "== Build and install first-wave apps =="
for entry in "${APPS[@]}"; do
  scheme="${entry%%:*}"
  rest="${entry#*:}"
  bundle="${rest%%:*}"
  slug="${rest#*:}"
  echo "building $scheme ($bundle)..."
  xcodebuild build \
    -project UnnecessaryApps.xcodeproj \
    -scheme "$scheme" \
    -destination "platform=iOS Simulator,id=$UDID" \
    -quiet
  app_path="$(find ~/Library/Developer/Xcode/DerivedData -name "${scheme}.app" -path "*/Build/Products/*-iphonesimulator/*" -print -quit)"
  if [[ -z "$app_path" ]]; then
    echo "error: could not locate built app for $scheme" >&2
    exit 1
  fi
  xcrun simctl install "$UDID" "$app_path"
  xcrun simctl terminate "$UDID" "$bundle" 2>/dev/null || true
  xcrun simctl launch "$UDID" "$bundle" >/dev/null
  sleep 2
  raw="$RAW_DIR/${slug}-qa.png"
  xcrun simctl io "$UDID" screenshot "$raw"
  sips -s format png -z 2736 1260 "$raw" --out "$OUT_DIR/${slug}.png" >/dev/null
  echo "  -> $OUT_DIR/${slug}.png"
done

echo "captured ${#APPS[@]} first-wave screenshots at 1260x2736"
