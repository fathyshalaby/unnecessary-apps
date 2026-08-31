#!/usr/bin/env python3
"""Write config/app-manifest.json — canonical list of all 44 active apps."""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
METADATA = json.loads((ROOT / "release/app-store-metadata.json").read_text(encoding="utf-8"))
OUT = ROOT / "config/app-manifest.json"

SCHEMES_AND_FOLDERS = [
    ("App01ChairFinder", "01-chair-finder"),
    ("App02BathroomMap", "02-public-bathroom-quality-map"),
    ("App03DoNotTextThem", "03-do-not-text-them"),
    ("App04SocialBatteryReceipt", "04-social-battery-receipt"),
    ("App05FridgeWitness", "05-fridge-witness"),
    ("App06ReceiptEmotionalDamage", "06-receipt-emotional-damage"),
    ("App07SockTribunal", "07-sock-tribunal"),
    ("App08PlantCourt", "08-plant-court"),
    ("App09LaundryMountain", "09-laundry-mountain"),
    ("App10WhatWasIDoing", "10-what-was-i-doing"),
    ("App11AmIEarly", "11-am-i-early"),
    ("App12PigeonOrSeagull", "12-pigeon-or-seagull"),
    ("App13ToiletTimer", "13-toilet-timer"),
    ("App14OneMoreEpisode", "14-one-more-episode"),
    ("App15CanIWearThisAgain", "15-can-i-wear-this-again"),
    ("App16MicrowaveSommelier", "16-microwave-sommelier"),
    ("App17MeetingBingo", "17-meeting-bingo-for-one"),
    ("App18TinyGratitude", "18-tiny-gratitude"),
    ("App19MedievalAdvice", "19-medieval-peasant-advice"),
    ("App20RealEmail", "20-is-this-a-real-email"),
    ("App21VibeMeter", "21-the-vibe-meter"),
    ("App22SnackRoulette", "22-snack-roulette"),
    ("App23QuietCafe", "23-quiet-cafe-index"),
    ("App24DogNameGuesser", "24-dog-name-guesser"),
    ("App25WaitingRoom", "25-waiting-room-simulator"),
    ("App26NeighborNoise", "26-neighbor-noise-translator"),
    ("App27TinyMuseum", "27-tiny-personal-museum"),
    ("App28OverthinkingBoard", "28-overthinking-evidence-board"),
    ("App29BenchReviews", "29-local-bench-reviews"),
    ("App30ApologyDraft", "30-apology-draft-generator"),
    ("App31HumanGPS", "31-human-gps"),
    ("App32LastSlice", "32-the-last-slice"),
    ("App33QueuePersonality", "33-queue-personality-test"),
    ("App34WeatherOutfit", "34-weather-outfit-excuse"),
    ("App35DoorWasPush", "35-the-door-was-push"),
    ("App36StepDebt", "36-step-debt"),
    ("App37SleepAlibi", "37-sleep-alibi"),
    ("App38HeartRateEmail", "38-heart-rate-during-email"),
    ("App39WorkoutExcuse", "39-workout-excuse-detector"),
    ("App40HealthHoroscope", "40-health-data-horoscope"),
    ("App41RecoveryGoblin", "41-the-recovery-goblin"),
    ("App42WalkingMeeting", "42-walking-meeting-escape-plan"),
    ("App43HydrationNarc", "43-hydration-narc"),
    ("App44RestDayPolice", "44-rest-day-police"),
]

SCREENSHOT_SOURCES = [
    "chair-finder-qa.png",
    "bathroom-map-qa.png",
    "do-not-text-qa.png",
    "social-battery-qa.png",
    "fridge-witness-qa.png",
    "receipt-damage-qa.png",
    "sock-tribunal-qa.png",
    "plant-court-qa.png",
    "laundry-mountain-qa.png",
    "what-was-i-doing-qa.png",
    "am-i-early-qa.png",
    "pigeon-or-seagull-qa.png",
    "toilet-timer-qa.png",
    "one-more-episode-qa.png",
    "can-i-wear-again-qa.png",
    "microwave-sommelier-qa.png",
    "meeting-bingo-qa.png",
    "tiny-gratitude-qa.png",
    "medieval-advice-qa.png",
    "real-email-qa.png",
    "vibe-meter-qa.png",
    "snack-roulette-qa.png",
    "quiet-cafe-qa.png",
    "dog-name-qa.png",
    "waiting-room-qa.png",
    "neighbor-noise-qa.png",
    "tiny-museum-qa.png",
    "overthinking-qa.png",
    "bench-reviews-qa.png",
    "apology-draft-qa.png",
    "human-gps-qa.png",
    "last-slice-qa.png",
    "queue-personality-qa.png",
    "weather-outfit-qa.png",
    "door-was-push-qa.png",
    "step-debt-qa.png",
    "sleep-alibi-qa.png",
    "heart-rate-email-qa.png",
    "workout-excuse-qa.png",
    "health-horoscope-qa.png",
    "recovery-goblin-qa.png",
    "walking-meeting-qa.png",
    "hydration-narc-qa.png",
    "rest-day-police-qa.png",
]

meta_by_folder = {entry["folder"]: entry for entry in METADATA["apps"]}


def slug_from_folder(folder: str) -> str:
    return re.sub(r"^\d+-", "", folder)


def main() -> None:
    if len(SCHEMES_AND_FOLDERS) != 44 or len(SCREENSHOT_SOURCES) != 44:
        raise SystemExit("SCHEMES_AND_FOLDERS and SCREENSHOT_SOURCES must contain 44 entries")

    apps = []
    for index, ((scheme, folder), source) in enumerate(
        zip(SCHEMES_AND_FOLDERS, SCREENSHOT_SOURCES, strict=True), start=1
    ):
        entry = meta_by_folder[folder]
        apps.append(
            {
                "number": index,
                "scheme": scheme,
                "folder": folder,
                "bundle_id": entry["bundle_id"],
                "name": entry["name"],
                "slug": slug_from_folder(folder),
                "screenshot_source": source,
                "priority": entry.get("priority", ""),
                "hold": entry.get("priority") == "HOLD",
                "release_wave": entry.get("release_wave", 0),
                "review_notes": entry.get("review_notes", ""),
            }
        )

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps({"apps": apps}, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {OUT} ({len(apps)} apps)")


if __name__ == "__main__":
    main()
