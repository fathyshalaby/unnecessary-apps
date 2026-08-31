#!/usr/bin/env zsh
# Capture App Store screenshots for all 44 active apps on Mac.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
DEVICE_NAME="${SIMULATOR_DEVICE:-iPhone 16e}"
RAW_DIR="docs/screenshots/raw"
OUT_DIR="release/screenshots/iphone-6.9"

python3 tools/generate_app_manifest.py
python3 tools/generate_xcode_project.py
mkdir -p "$RAW_DIR" "$OUT_DIR"

UDID="$(xcrun simctl list devices available "$DEVICE_NAME" | grep -Eo '[0-9A-F-]{36}' | head -1)"
if [[ -z "$UDID" ]]; then
  echo "error: no available simulator named $DEVICE_NAME" >&2
  exit 1
fi

xcrun simctl boot "$UDID" 2>/dev/null || true
open -a Simulator --args -CurrentDeviceUDID "$UDID"

python3 - <<'PY'
import json
from pathlib import Path

manifest = json.loads(Path("config/app-manifest.json").read_text())
for app in manifest["apps"]:
    print(f"{app['scheme']}\t{app['bundle_id']}\t{app['screenshot_source']}\t{app['number']:02d}")
PY
| while IFS=$'\t' read -r scheme bundle source number; do
  echo "== App${number} $scheme =="
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
  raw="$RAW_DIR/$source"
  xcrun simctl io "$UDID" screenshot "$raw"
  sips -s format png -z 2736 1260 "$raw" --out "$OUT_DIR/App${number}.png" >/dev/null
  echo "  -> $OUT_DIR/App${number}.png"
done

echo "captured 44 screenshots at 1260x2736"
