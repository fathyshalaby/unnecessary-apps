#!/usr/bin/env python3
"""Build the canonical 44-app TestFlight manifest without mutating Xcode."""

from __future__ import annotations

import argparse
import base64
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

TARGETS = [
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


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def parse_app_numbers(spec: str) -> set[int]:
    """Parse the same comma-separated numbers/ranges accepted by the release lane."""
    if not spec.strip():
        return set()

    selected: set[int] = set()
    for token in (part.strip() for part in spec.split(",")):
        if not token:
            continue
        if "-" in token:
            pieces = token.split("-")
            if len(pieces) != 2 or not all(piece.isdigit() for piece in pieces):
                raise SystemExit(f"Invalid app selection: {token}")
            start, end = (int(piece) for piece in pieces)
            if start > end:
                raise SystemExit(f"Invalid app selection range: {token}")
            selected.update(range(start, end + 1))
        elif token.isdigit():
            selected.add(int(token))
        else:
            raise SystemExit(f"Invalid app selection: {token}")

    return selected


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path)
    parser.add_argument(
        "--app-numbers",
        default="",
        help="comma-separated app numbers/ranges whose App Store Connect records are required",
    )
    parser.add_argument(
        "--require-app-records",
        action="store_true",
        help="fail unless every target has a recorded App Store Connect app ID",
    )
    args = parser.parse_args()

    metadata = load_json(ROOT / "release" / "app-store-metadata.json")["apps"]
    by_folder = {item["folder"]: item for item in metadata}
    build_numbers = load_json(ROOT / "config" / "build-numbers.json")
    records = load_json(ROOT / "config" / "app-store-connect-apps.json")

    if len(TARGETS) != 44 or len(metadata) != 44:
        raise SystemExit("Expected exactly 44 targets and 44 metadata entries.")

    missing_folders = [folder for _, folder in TARGETS if folder not in by_folder]
    if missing_folders:
        raise SystemExit(f"Missing metadata folders: {', '.join(missing_folders)}")

    selected_numbers = parse_app_numbers(args.app_numbers)
    required_targets = [
        (scheme, folder)
        for scheme, folder in TARGETS
        if not selected_numbers or by_folder[folder]["number"] in selected_numbers
    ]
    missing_records = [scheme for scheme, _ in required_targets if scheme not in records]
    if args.require_app_records and missing_records:
        raise SystemExit(
            f"Missing {len(missing_records)} App Store Connect records: "
            + ", ".join(missing_records)
        )

    lines = [
        "number\tscheme\tfolder\tbundle_id\tbuild_number\tapp_store_id\tname\twhat_to_test_base64"
    ]
    for scheme, folder in TARGETS:
        item = by_folder[folder]
        note = item["review_notes"].strip()
        note64 = base64.b64encode(note.encode("utf-8")).decode("ascii")
        lines.append(
            "\t".join(
                [
                    str(item["number"]),
                    scheme,
                    folder,
                    item["bundle_id"],
                    str(build_numbers.get(scheme, 1)),
                    records.get(scheme, ""),
                    item["name"].replace("\t", " "),
                    note64,
                ]
            )
        )

    output = "\n".join(lines) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(output, encoding="utf-8")
    else:
        print(output, end="")

    print(
        f"prepared 44 targets; {len(records)} App Store Connect records known; "
        f"{len(missing_records)} required records still missing",
        file=__import__("sys").stderr,
    )


if __name__ == "__main__":
    main()
