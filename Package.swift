// swift-tools-version: 6.0
import PackageDescription

let apps: [(String, String)] = [
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

let package = Package(
    name: "UnnecessaryAppsCorp",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: apps.map { .executable(name: $0.0, targets: [$0.0]) } + [.library(name: "DumbKit", targets: ["DumbKit"])],
    targets: [.target(name: "DumbKit", path: "shared", exclude: ["README.md"])] + apps.map {
        .executableTarget(name: $0.0, dependencies: ["DumbKit"], path: $0.1, exclude: ["README.md"])
    }
)
