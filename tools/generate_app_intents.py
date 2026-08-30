#!/usr/bin/env python3
"""Generate App Intents + Shortcuts for apps that do not already have them."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

APPS = [
    ("App01ChairFinder", "01-chair-finder", "Rank the chairs", "rank", "chair.fill"),
    ("App02BathroomMap", "02-public-bathroom-quality-map", "Open bathroom map", "open", "map.fill"),
    ("App04SocialBatteryReceipt", "04-social-battery-receipt", "Print social battery receipt", "print", "battery.100.bolt"),
    ("App05FridgeWitness", "05-fridge-witness", "Check the fridge", "open", "refrigerator.fill"),
    ("App06ReceiptEmotionalDamage", "06-receipt-emotional-damage", "Assess the damage", "assess", "doc.text.fill"),
    ("App07SockTribunal", "07-sock-tribunal", "Open sock tribunal", "open", "wind"),
    ("App08PlantCourt", "08-plant-court", "Open plant court", "open", "leaf.fill"),
    ("App09LaundryMountain", "09-laundry-mountain", "Check laundry mountain", "open", "tshirt.fill"),
    ("App10WhatWasIDoing", "10-what-was-i-doing", "Log what I was doing", "log", "questionmark.circle.fill"),
    ("App11AmIEarly", "11-am-i-early", "Rate my punctuality", "rate", "clock.fill"),
    ("App12PigeonOrSeagull", "12-pigeon-or-seagull", "Identify the bird", "identify", "camera.fill"),
    ("App14OneMoreEpisode", "14-one-more-episode", "Forecast one more episode", "forecast", "tv.fill"),
    ("App15CanIWearThisAgain", "15-can-i-wear-this-again", "Rule on this outfit", "rule", "tshirt"),
    ("App16MicrowaveSommelier", "16-microwave-sommelier", "Convert microwave time", "convert", "timer"),
    ("App17MeetingBingo", "17-meeting-bingo-for-one", "Start meeting bingo", "start", "square.grid.3x3.fill"),
    ("App18TinyGratitude", "18-tiny-gratitude", "Log tiny gratitude", "log", "heart.fill"),
    ("App19MedievalAdvice", "19-medieval-peasant-advice", "Ask the peasant", "ask", "person.fill.questionmark"),
    ("App20RealEmail", "20-is-this-a-real-email", "Analyze this email", "analyze", "envelope.fill"),
    ("App21VibeMeter", "21-the-vibe-meter", "Read the vibe", "read", "waveform.path.ecg"),
    ("App22SnackRoulette", "22-snack-roulette", "Spin snack roulette", "spin", "dice.fill"),
    ("App23QuietCafe", "23-quiet-cafe-index", "Open café index", "open", "cup.and.saucer.fill"),
    ("App24DogNameGuesser", "24-dog-name-guesser", "Guess the dog name", "guess", "pawprint.fill"),
    ("App25WaitingRoom", "25-waiting-room-simulator", "Start waiting room", "start", "hourglass"),
    ("App26NeighborNoise", "26-neighbor-noise-translator", "Translate the noise", "translate", "ear.fill"),
    ("App27TinyMuseum", "27-tiny-personal-museum", "Open tiny museum", "open", "building.columns.fill"),
    ("App28OverthinkingBoard", "28-overthinking-evidence-board", "Open evidence board", "open", "pin.fill"),
    ("App29BenchReviews", "29-local-bench-reviews", "Open bench reviews", "open", "figure.seated.side"),
    ("App31HumanGPS", "31-human-gps", "Get human directions", "direct", "location.fill"),
    ("App32LastSlice", "32-the-last-slice", "Settle last slice", "settle", "fork.knife"),
    ("App33QueuePersonality", "33-queue-personality-test", "Start queue session", "start", "person.3.sequence.fill"),
    ("App34WeatherOutfit", "34-weather-outfit-excuse", "Generate outfit defense", "defend", "cloud.sun.fill"),
    ("App35DoorWasPush", "35-the-door-was-push", "Settle push or pull", "settle", "door.left.hand.open"),
    ("App37SleepAlibi", "37-sleep-alibi", "Check sleep alibi", "check", "bed.double.fill"),
    ("App38HeartRateEmail", "38-heart-rate-during-email", "Record inbox drama", "record", "heart.fill"),
    ("App39WorkoutExcuse", "39-workout-excuse-detector", "Judge my excuse", "judge", "figure.run"),
    ("App40HealthHoroscope", "40-health-data-horoscope", "Read today's horoscope", "read", "sparkles"),
    ("App41RecoveryGoblin", "41-the-recovery-goblin", "Check in with goblin", "checkin", "figure.cooldown"),
    ("App42WalkingMeeting", "42-walking-meeting-escape-plan", "Start walking meeting", "start", "figure.walk"),
    ("App44RestDayPolice", "44-rest-day-police", "Check rest-day streak", "check", "figure.walk.circle"),
]

TEMPLATE = '''import AppIntents
import DumbKit

struct {intent_name}: AppIntent {{
    static var title: LocalizedStringResource = "{title}"
    static var description = IntentDescription("{description}")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {{
        DumbPendingLaunch.queue(action: "{action}")
        return .result()
    }}
}}

struct {provider_name}: AppShortcutsProvider {{
    static var appShortcuts: [AppShortcut] {{
        AppShortcut(
            intent: {intent_name}(),
            phrases: [
                "{title} in \\(.applicationName)",
                "{phrase_alt} with \\(.applicationName)"
            ],
            shortTitle: "{short_title}",
            systemImageName: "{symbol}"
        )
    }}
}}
'''

SKIP = {
    "03-do-not-text-them",
    "13-toilet-timer",
    "30-apology-draft-generator",
    "36-step-debt",
    "43-hydration-narc",
}


def intent_name(target: str) -> str:
    core = target.removeprefix("App")
    return f"{core}Intent"


def provider_name(target: str) -> str:
    return f"{target}Shortcuts"


def main() -> None:
    created = 0
    for target, slug, title, action, symbol in APPS:
        if slug in SKIP:
            continue
        path = ROOT / slug / f"{target.removeprefix('App')}Intents.swift"
        if path.exists():
            continue
        short = title.split()[0] if title else "Open"
        content = TEMPLATE.format(
            intent_name=intent_name(target),
            provider_name=provider_name(target),
            title=title,
            description=f"Open {title.lower()} in the app.",
            action=action,
            phrase_alt=title,
            short_title=short[:20],
            symbol=symbol,
        )
        path.write_text(content, encoding="utf-8")
        created += 1
        print(f"created {path.relative_to(ROOT)}")
    print(f"done — {created} intent files")


if __name__ == "__main__":
    main()
