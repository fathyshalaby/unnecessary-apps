#!/usr/bin/env zsh
# Interactive first-wave demo recorder — one app at a time.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
DEVICE_NAME="${SIMULATOR_DEVICE:-iPhone 16e}"
DEMO_DIR="release/demos/first-wave"

mkdir -p "$DEMO_DIR"

APPS=(
  "corp.unecessary.app20realemail:01-real-email"
  "corp.unecessary.app03donottextthem:02-do-not-text"
  "corp.unecessary.app10whatwasidoing:03-what-was-i-doing"
  "corp.unecessary.app18tinygratitude:04-tiny-gratitude"
  "corp.unecessary.app28overthinkingboard:05-overthinking-board"
  "corp.unecessary.app43hydrationnarc:06-hydration-narc"
  "corp.unecessary.app13toilettimer:07-toilet-timer"
  "corp.unecessary.app17meetingbingo:08-meeting-bingo"
  "corp.unecessary.app22snackroulette:09-snack-roulette"
  "corp.unecessary.app11amiearly:10-am-i-early"
)

UDID="$(xcrun simctl list devices available "$DEVICE_NAME" | grep -Eo '[0-9A-F-]{36}' | head -1)"
if [[ -z "$UDID" ]]; then
  echo "error: no available simulator named $DEVICE_NAME" >&2
  exit 1
fi

xcrun simctl boot "$UDID" 2>/dev/null || true
open -a Simulator --args -CurrentDeviceUDID "$UDID"

echo "Follow release/FIRST_WAVE_DEMO_SCRIPTS.md for each app."
echo "Press Enter to start recording; press Enter again to stop."
echo ""

for entry in "${APPS[@]}"; do
  bundle="${entry%%:*}"
  slug="${entry#*:}"
  out="$DEMO_DIR/${slug}.mp4"
  echo "== $slug =="
  xcrun simctl terminate "$UDID" "$bundle" 2>/dev/null || true
  xcrun simctl launch "$UDID" "$bundle" >/dev/null
  sleep 1
  read "?Press Enter to START recording..."
  xcrun simctl io "$UDID" recordVideo --codec=h264 --force "$out" &
  rec_pid=$!
  read "?Perform demo steps, then press Enter to STOP..."
  kill -INT "$rec_pid" 2>/dev/null || true
  wait "$rec_pid" 2>/dev/null || true
  echo "  saved $out"
  echo ""
done

echo "done — review clips in $DEMO_DIR"
