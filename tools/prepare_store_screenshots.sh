#!/bin/zsh

set -euo pipefail

output_dir="release/screenshots/iphone-6.9"
mkdir -p "$output_dir"

sources=(
  chair-finder-qa.png
  bathroom-map-qa.png
  do-not-text-qa.png
  social-battery-qa.png
  fridge-witness-qa.png
  receipt-damage-qa.png
  sock-tribunal-qa.png
  plant-court-qa.png
  laundry-mountain-qa.png
  what-was-i-doing-qa.png
  am-i-early-qa.png
  pigeon-or-seagull-qa.png
  toilet-timer-qa.png
  one-more-episode-qa.png
  can-i-wear-again-qa.png
  microwave-sommelier-qa.png
  meeting-bingo-qa.png
  tiny-gratitude-qa.png
  medieval-advice-qa.png
  real-email-qa.png
  vibe-meter-qa.png
  snack-roulette-qa.png
  quiet-cafe-qa.png
  dog-name-qa.png
  waiting-room-qa.png
  neighbor-noise-qa.png
  tiny-museum-qa.png
  overthinking-qa.png
  bench-reviews-qa.png
  apology-draft-qa.png
  human-gps-qa.png
  last-slice-qa.png
  queue-personality-qa.png
  weather-outfit-qa.png
  door-was-push-qa.png
  step-debt-qa.png
  sleep-alibi-qa.png
  heart-rate-email-qa.png
  workout-excuse-qa.png
  health-horoscope-qa.png
  recovery-goblin-qa.png
  walking-meeting-qa.png
  hydration-narc-qa.png
  rest-day-police-qa.png
)

index=1
for source in "${sources[@]}"; do
  number=$(printf '%02d' "$index")
  destination="$output_dir/App${number}.png"
  test -f "docs/screenshots/$source"
  sips -s format png -z 2736 1260 "docs/screenshots/$source" --out "$destination" >/dev/null
  index=$((index + 1))
done

echo "prepared ${#sources[@]} screenshots at 1260x2736"
