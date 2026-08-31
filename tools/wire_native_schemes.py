#!/usr/bin/env python3
"""Attach dumbNativeEntry to every app WindowGroup for URL + Shortcuts routing."""

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

APPS = [
    ("App01ChairFinder", "01-chair-finder"),
    ("App02BathroomMap", "02-public-bathroom-quality-map"),
    ("App04SocialBatteryReceipt", "04-social-battery-receipt"),
    ("App05FridgeWitness", "05-fridge-witness"),
    ("App06ReceiptEmotionalDamage", "06-receipt-emotional-damage"),
    ("App07SockTribunal", "07-sock-tribunal"),
    ("App08PlantCourt", "08-plant-court"),
    ("App09LaundryMountain", "09-laundry-mountain"),
    ("App10WhatWasIDoing", "10-what-was-i-doing"),
    ("App11AmIEarly", "11-am-i-early"),
    ("App12PigeonOrSeagull", "12-pigeon-or-seagull"),
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
    ("App31HumanGPS", "31-human-gps"),
    ("App32LastSlice", "32-the-last-slice"),
    ("App33QueuePersonality", "33-queue-personality-test"),
    ("App34WeatherOutfit", "34-weather-outfit-excuse"),
    ("App35DoorWasPush", "35-the-door-was-push"),
    ("App37SleepAlibi", "37-sleep-alibi"),
    ("App38HeartRateEmail", "38-heart-rate-during-email"),
    ("App39WorkoutExcuse", "39-workout-excuse-detector"),
    ("App40HealthHoroscope", "40-health-data-horoscope"),
    ("App41RecoveryGoblin", "41-the-recovery-goblin"),
    ("App42WalkingMeeting", "42-walking-meeting-escape-plan"),
    ("App44RestDayPolice", "44-rest-day-police"),
]

PATTERN = re.compile(r"WindowGroup\s*\{\s*([A-Za-z0-9_]+)\(\s*\)\s*\}")
VIEW_NAME = re.compile(r"struct (\w+(?:View|ContentView))\s*:")


def resolve_view_name(app_file: Path, text: str) -> str | None:
    match = PATTERN.search(text)
    if match:
        return match.group(1)
    for sibling in sorted(app_file.parent.glob("*.swift")):
        if sibling == app_file:
            continue
        sibling_text = sibling.read_text(encoding="utf-8")
        if view_match := VIEW_NAME.search(sibling_text):
            return view_match.group(1)
    return None


def main() -> None:
    updated = 0
    for target, slug in APPS:
        scheme = target.lower()
        for app_file in sorted((ROOT / slug).glob("*App.swift")):
            text = app_file.read_text(encoding="utf-8")
            if "dumbNativeEntry" in text:
                continue
            if "import DumbKit" not in text:
                text = text.replace("import SwiftUI", "import SwiftUI\nimport DumbKit", 1)
            match = PATTERN.search(text)
            view_name = resolve_view_name(app_file, text)
            if not view_name:
                continue
            replacement = f'WindowGroup {{ {view_name}().dumbNativeEntry(scheme: "{scheme}") {{ _, _ in }} }}'
            if match:
                new_text = PATTERN.sub(replacement, text, count=1)
            else:
                broken = re.compile(
                    r'WindowGroup\s*\{\s*\x01\(\)\.dumbNativeEntry\(scheme:\s*"[^"]+"\)\s*\{\s*_,\s*_\s+in\s*\}\s*\}'
                )
                if not broken.search(text):
                    continue
                new_text = broken.sub(replacement, text, count=1)
            app_file.write_text(new_text, encoding="utf-8")
            updated += 1
            print(f"wired {app_file.relative_to(ROOT)}")
    print(f"done — {updated} app entry files")


if __name__ == "__main__":
    main()
