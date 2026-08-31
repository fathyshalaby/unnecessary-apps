#!/usr/bin/env zsh
# Interactive demo recorder for all 44 active apps.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
DEVICE_NAME="${SIMULATOR_DEVICE:-iPhone 16e}"
DEMO_DIR="release/demos/all-apps"

python3 tools/generate_app_manifest.py
python3 tools/generate_demo_scripts.py
mkdir -p "$DEMO_DIR"

UDID="$(xcrun simctl list devices available "$DEVICE_NAME" | grep -Eo '[0-9A-F-]{36}' | head -1)"
if [[ -z "$UDID" ]]; then
  echo "error: no available simulator named $DEVICE_NAME" >&2
  exit 1
fi

xcrun simctl boot "$UDID" 2>/dev/null || true
open -a Simulator --args -CurrentDeviceUDID "$UDID"

echo "Follow release/ALL_APPS_DEMO_SCRIPTS.md for each app."
echo "Press Enter to start recording; press Enter again to stop."
echo "Skip any app by typing 's' at the start prompt."
echo ""

python3 - <<'PY'
import json
from pathlib import Path

for app in json.loads(Path("config/app-manifest.json").read_text())["apps"]:
    filename = f"{app['number']:02d}-{app['slug']}.mp4"
    hold = " [HOLD]" if app["hold"] else ""
    print(f"{app['bundle_id']}\t{filename}\t{app['name']}{hold}\t{app['scheme']}")
PY
| while IFS=$'\t' read -r bundle out name scheme; do
  echo "== $name =="
  xcrun simctl terminate "$UDID" "$bundle" 2>/dev/null || true
  if ! xcrun simctl launch "$UDID" "$bundle" >/dev/null 2>&1; then
    echo "  installing $scheme..."
    xcodebuild build -project UnnecessaryApps.xcodeproj -scheme "$scheme" -destination "platform=iOS Simulator,id=$UDID" -quiet
    app_path="$(find ~/Library/Developer/Xcode/DerivedData -name "${scheme}.app" -path "*/Build/Products/*-iphonesimulator/*" -print -quit)"
    xcrun simctl install "$UDID" "$app_path"
    xcrun simctl launch "$UDID" "$bundle" >/dev/null
  fi
  sleep 1
  read "reply?Press Enter to START (s to skip)... "
  if [[ "$reply" == "s" ]]; then
    echo "  skipped"
    echo ""
    continue
  fi
  clip="$DEMO_DIR/$out"
  xcrun simctl io "$UDID" recordVideo --codec=h264 --force "$clip" &
  rec_pid=$!
  read "?Perform demo steps, then press Enter to STOP..."
  kill -INT "$rec_pid" 2>/dev/null || true
  wait "$rec_pid" 2>/dev/null || true
  echo "  saved $clip"
  echo ""
done

echo "done — review clips in $DEMO_DIR"
