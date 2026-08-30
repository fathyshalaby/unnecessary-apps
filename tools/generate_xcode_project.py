#!/usr/bin/env python3
"""Generate the 44-target Xcode project for Unnecessary Apps Corp."""

from hashlib import sha1
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROJECT_DIR = ROOT / "UnnecessaryApps.xcodeproj"
PROJECT_FILE = PROJECT_DIR / "project.pbxproj"
TEAM_ID_FILE = ROOT / "config" / "development_team_id.txt"
DEVELOPMENT_TEAM = TEAM_ID_FILE.read_text(encoding="utf-8").strip() if TEAM_ID_FILE.exists() else ""
BUILD_NUMBERS_FILE = ROOT / "config" / "build-numbers.json"
BUILD_NUMBERS = json.loads(BUILD_NUMBERS_FILE.read_text(encoding="utf-8")) if BUILD_NUMBERS_FILE.exists() else {}
METADATA_FILE = ROOT / "release" / "app-store-metadata.json"
METADATA_APPS = json.loads(METADATA_FILE.read_text(encoding="utf-8"))["apps"] if METADATA_FILE.exists() else []
DISPLAY_NAMES = {
    item["folder"]: item["name"].removeprefix("Unnecessary: ")
    for item in METADATA_APPS
}

APPS = [
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

HEALTHKIT_CONFIG = {
    "App36StepDebt": (
        "config/App36StepDebt.entitlements",
        "Step Debt reads today\'s step count to calculate the fictional invoice. It never writes health data.",
        "Step Debt requests HealthKit access only to read steps for its fictional invoice. It never writes or updates Health data.",
    ),
    "App37SleepAlibi": (
        "config/App37SleepAlibi.entitlements",
        "Sleep Alibi reads sleep samples from Apple Health to create a fictional alibi. It never writes health data.",
        "Sleep Alibi requests HealthKit access only to read sleep samples for its fictional alibi. It never writes or updates Health data.",
    ),
    "App39WorkoutExcuse": (
        "config/App39WorkoutExcuse.entitlements",
        "Workout Excuse Detector reads today's workout durations from Apple Health to create a playful local audit. It never writes health data.",
        "Workout Excuse Detector requests HealthKit access only to read workout durations for its playful local audit. It never writes or updates Health data.",
    ),
    "App40HealthHoroscope": (
        "config/App40HealthHoroscope.entitlements",
        "Health Data Horoscope reads optional step and sleep samples from Apple Health for entertainment only. It never writes health data.",
        "Health Data Horoscope requests HealthKit access only to read optional steps and sleep for an entertainment-only horoscope. It never writes or updates Health data.",
    ),
    "App41RecoveryGoblin": (
        "config/App41RecoveryGoblin.entitlements",
        "The Recovery Goblin reads optional workout duration from Apple Health as context for a playful check-in. It never writes health data.",
        "The Recovery Goblin requests HealthKit access only to read optional workout duration for a playful check-in. It never writes or updates Health data.",
    ),
    "App43HydrationNarc": (
        "config/App43HydrationNarc.entitlements",
        "Hydration Narc reads optional water entries from Apple Health to show a separate read-only ledger. It never writes health data.",
        "Hydration Narc requests HealthKit access only to read optional water entries for a separate read-only ledger. It never writes or updates Health data.",
    ),
    "App44RestDayPolice": (
        "config/App44RestDayPolice.entitlements",
        "Rest Day Police reads optional workout entries from Apple Health to estimate a recent activity streak. It never writes health data.",
        "Rest Day Police requests HealthKit access only to read optional workout entries for a recent activity streak. It never writes or updates Health data.",
    ),
}
MICROPHONE_TARGETS = {"App26NeighborNoise"}
CAMERA_USAGE_DESCRIPTIONS = {
    "App12PigeonOrSeagull": "Pigeon or Seagull uses the camera only when you ask it to photograph a bird for the bureau.",
    "App24DogNameGuesser": "Dog Name Guesser uses the camera only when you ask it to photograph a dog for the name committee.",
    "App27TinyMuseum": "Tiny Personal Museum uses the camera only when you ask it to photograph an exhibit for your collection.",
}
LOCATION_USAGE_DESCRIPTIONS = {
    "App02BathroomMap": "Bathroom Quality Map uses your location only when you ask it to center the restroom map near you. Private reports and coordinates stay on this device.",
    "App23QuietCafe": "Quiet Café Index uses your location only when you ask it to center the café map near you. Private ratings and coordinates stay on this device.",
    "App29BenchReviews": "Local Bench Reviews uses your location only when you ask it to center the map near you. Reviews and coordinates stay on this device.",
    "App36StepDebt": "Step Debt uses your location only when you ask it to find a nearby walking route. It does not store or upload your location.",
}
APP_EXTENSION_ONLY_SOURCES = {
    "App13ToiletTimer": {"ToiletTimerLiveActivity.swift"},
}


def uid(label: str) -> str:
    return sha1(label.encode()).hexdigest()[:24].upper()


objects = {}


def add(label: str, body: str) -> str:
    ident = uid(label)
    if body.startswith(("PBX", "XC")):
        body = body.split(" = ", 1)[1]
    objects[ident] = body
    return ident


def file_ref(label: str, path: str, file_type: str = "sourcecode.swift") -> str:
    return add(label, f"PBXFileReference = {{\n\t\tisa = PBXFileReference;\n\t\tfileEncoding = 4;\n\t\tlastKnownFileType = {file_type};\n\t\tpath = {path};\n\t\tsourceTree = \"<group>\";\n\t}};")


products_group_children = []
app_target_ids = []
app_target_by_name = {}
app_groups = []

shared_source_names = sorted(path.name for path in (ROOT / "shared").glob("*.swift"))
shared_file_ids = [
    file_ref(f"shared/{name}", name)
    for name in shared_source_names
]
shared_group = add(
    "group/shared",
    "PBXGroup = {\n\t\tisa = PBXGroup;\n\t\tchildren = (\n\t\t\t%s\n\t\t);\n\t\tpath = shared;\n\t\tsourceTree = \"<group>\";\n\t};" % "\n\t\t\t".join(f"{x}," for x in shared_file_ids),
)

library_product = file_ref("product/DumbKit", "libDumbKit.a", "archive.ar")
products_group_children.append(library_product)

debug_project = add(
    "config/project/debug",
    "XCBuildConfiguration = {\n\t\tisa = XCBuildConfiguration;\n\t\tbuildSettings = {\n\t\t\tALWAYS_SEARCH_USER_PATHS = NO;\n\t\t\tCLANG_ENABLE_MODULES = YES;\n\t\t\tSWIFT_VERSION = 5.0;\n\t\t};\n\t\tname = Debug;\n\t};",
)
release_project = add(
    "config/project/release",
    "XCBuildConfiguration = {\n\t\tisa = XCBuildConfiguration;\n\t\tbuildSettings = {\n\t\t\tALWAYS_SEARCH_USER_PATHS = NO;\n\t\t\tCLANG_ENABLE_MODULES = YES;\n\t\t\tSWIFT_VERSION = 5.0;\n\t\t};\n\t\tname = Release;\n\t};",
)
project_config_list = add(
    "config/project/list",
    f"XCConfigurationList = {{\n\t\tisa = XCConfigurationList;\n\t\tbuildConfigurations = (\n\t\t\t{debug_project},\n\t\t\t{release_project},\n\t\t);\n\t\tdefaultConfigurationIsVisible = 0;\n\t\tdefaultConfigurationName = Release;\n\t}};",
)

library_sources = []
for source_id in shared_file_ids:
    build_id = add(f"build/library/{source_id}", f"PBXBuildFile = {{\n\t\tisa = PBXBuildFile;\n\t\tfileRef = {source_id};\n\t}};")
    library_sources.append(build_id)
library_sources_phase = add(
    "phase/library/sources",
    f"PBXSourcesBuildPhase = {{\n\t\tisa = PBXSourcesBuildPhase;\n\t\tbuildActionMask = 2147483647;\n\t\tfiles = (\n\t\t\t{', '.join(x + ',' for x in library_sources)}\n\t\t);\n\t\trunOnlyForDeploymentPostprocessing = 0;\n\t}};",
)
library_frameworks_phase = add("phase/library/frameworks", "PBXFrameworksBuildPhase = { isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; };")
library_resources_phase = add("phase/library/resources", "PBXResourcesBuildPhase = { isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; };")
library_debug = add(
    "config/library/debug",
    "XCBuildConfiguration = {\n\t\tisa = XCBuildConfiguration;\n\t\tbuildSettings = {\n\t\t\tCODE_SIGNING_ALLOWED = NO;\n\t\t\tCODE_SIGNING_REQUIRED = NO;\n\t\t\tDEFINES_MODULE = YES;\n\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;\n\t\t\tMACH_O_TYPE = staticlib;\n\t\t\tPRODUCT_MODULE_NAME = DumbKit;\n\t\t\tPRODUCT_NAME = DumbKit;\n\t\t\tSKIP_INSTALL = YES;\n\t\t\tSDKROOT = iphoneos;\n\t\t\tSUPPORTED_PLATFORMS = \"iphoneos iphonesimulator\";\n\t\t\tTARGETED_DEVICE_FAMILY = \"1,2\";\n\t\t\tSWIFT_VERSION = 5.0;\n\t\t};\n\t\tname = Debug;\n\t};",
)
library_release = library_debug.replace(library_debug, add(
    "config/library/release",
    "XCBuildConfiguration = {\n\t\tisa = XCBuildConfiguration;\n\t\tbuildSettings = {\n\t\t\tCODE_SIGNING_ALLOWED = NO;\n\t\t\tCODE_SIGNING_REQUIRED = NO;\n\t\t\tDEFINES_MODULE = YES;\n\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;\n\t\t\tMACH_O_TYPE = staticlib;\n\t\t\tPRODUCT_MODULE_NAME = DumbKit;\n\t\t\tPRODUCT_NAME = DumbKit;\n\t\t\tSKIP_INSTALL = YES;\n\t\t\tSDKROOT = iphoneos;\n\t\t\tSUPPORTED_PLATFORMS = \"iphoneos iphonesimulator\";\n\t\t\tTARGETED_DEVICE_FAMILY = \"1,2\";\n\t\t\tSWIFT_OPTIMIZATION_LEVEL = \"-O\";\n\t\t\tSWIFT_VERSION = 5.0;\n\t\t};\n\t\tname = Release;\n\t};",
))
library_config_list = add(
    "config/library/list",
    f"XCConfigurationList = {{ isa = XCConfigurationList; buildConfigurations = ({library_debug}, {library_release}); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; }};",
)
library_target = add(
    "target/DumbKit",
    f"PBXNativeTarget = {{\n\t\tisa = PBXNativeTarget;\n\t\tbuildConfigurationList = {library_config_list};\n\t\tbuildPhases = ({library_sources_phase}, {library_frameworks_phase}, {library_resources_phase});\n\t\tbuildRules = ();\n\t\tdependencies = ();\n\t\tname = DumbKit;\n\t\tproductName = DumbKit;\n\t\tproductReference = {library_product};\n\t\tproductType = \"com.apple.product-type.library.static\";\n\t}};",
)


def app_settings(target: str, slug: str) -> str:
    display_name = DISPLAY_NAMES.get(slug, target)
    build_number = int(BUILD_NUMBERS.get(target, 1))
    settings = [
        "ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;",
        "CLANG_ENABLE_MODULES = YES;",
        "CODE_SIGNING_ALLOWED = YES;",
        "CODE_SIGNING_REQUIRED = YES;",
        "CODE_SIGN_STYLE = Manual;" if target == "App13ToiletTimer" else "CODE_SIGN_STYLE = Automatic;",
        f"CURRENT_PROJECT_VERSION = {build_number};",
        f'DEVELOPMENT_TEAM = "{DEVELOPMENT_TEAM}";',
        "GENERATE_INFOPLIST_FILE = YES;",
        f'INFOPLIST_KEY_CFBundleDisplayName = "{display_name}";',
        "INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO;",
        "INFOPLIST_KEY_UILaunchScreen_Generation = YES;",
        "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = \"UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight\";",
        "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = \"UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight\";",
        "IPHONEOS_DEPLOYMENT_TARGET = 17.0;",
        "LD_RUNPATH_SEARCH_PATHS = \"$(inherited) @executable_path/Frameworks\";",
        "MARKETING_VERSION = 1.0;",
        f"PRODUCT_BUNDLE_IDENTIFIER = corp.unecessary.{target.lower()};",
        "PRODUCT_NAME = \"$(TARGET_NAME)\";",
        "SDKROOT = iphoneos;",
        "SUPPORTED_PLATFORMS = \"iphoneos iphonesimulator\";",
        "SWIFT_VERSION = 5.0;",
        "TARGETED_DEVICE_FAMILY = \"1,2\";",
    ]
    if target in HEALTHKIT_CONFIG:
        entitlements_path, health_share_description, health_update_description = HEALTHKIT_CONFIG[target]
        settings.extend([
            f"CODE_SIGN_ENTITLEMENTS = {entitlements_path};",
            f'INFOPLIST_KEY_NSHealthShareUsageDescription = "{health_share_description}";',
            f'INFOPLIST_KEY_NSHealthUpdateUsageDescription = "{health_update_description}";',
        ])
    if target in MICROPHONE_TARGETS:
        settings.append('INFOPLIST_KEY_NSMicrophoneUsageDescription = "Neighbor Noise Translator listens for two seconds, classifies the volume locally, and saves no audio.";')
    if target in CAMERA_USAGE_DESCRIPTIONS:
        settings.append(f'INFOPLIST_KEY_NSCameraUsageDescription = "{CAMERA_USAGE_DESCRIPTIONS[target]}";')
    if target in LOCATION_USAGE_DESCRIPTIONS:
        settings.append(f'INFOPLIST_KEY_NSLocationWhenInUseUsageDescription = "{LOCATION_USAGE_DESCRIPTIONS[target]}";')
    if target == "App13ToiletTimer":
        settings.extend([
            'PROVISIONING_PROFILE_SPECIFIER = "Unnecessary Apps Store 13";',
            "INFOPLIST_KEY_NSSupportsLiveActivities = YES;",
        ])
    return "\n".join(settings)


live_activity_source_names = ["BathroomTimerActivity.swift", "ToiletTimerLiveActivity.swift"]
live_activity_source_refs = [
    file_ref(f"13-toilet-timer/{name}", name)
    for name in live_activity_source_names
]
live_activity_source_builds = [
    add(f"build/ToiletTimerLiveActivityExtension/{ref}", f"PBXBuildFile = {{ isa = PBXBuildFile; fileRef = {ref}; }};")
    for ref in live_activity_source_refs
]
live_activity_sources_phase = add(
    "phase/ToiletTimerLiveActivityExtension/sources",
    f"PBXSourcesBuildPhase = {{ isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = ({', '.join(x + ',' for x in live_activity_source_builds)}); runOnlyForDeploymentPostprocessing = 0; }};",
)
live_activity_frameworks_phase = add(
    "phase/ToiletTimerLiveActivityExtension/frameworks",
    "PBXFrameworksBuildPhase = { isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; };",
)
live_activity_resources_phase = add(
    "phase/ToiletTimerLiveActivityExtension/resources",
    "PBXResourcesBuildPhase = { isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; };",
)
live_activity_product = file_ref(
    "product/ToiletTimerLiveActivityExtension",
    "ToiletTimerLiveActivityExtension.appex",
    "wrapper.app-extension",
)
products_group_children.append(live_activity_product)


def live_activity_settings() -> str:
    return "\n".join([
        "APPLICATION_EXTENSION_API_ONLY = YES;",
        "CLANG_ENABLE_MODULES = YES;",
        "CODE_SIGNING_ALLOWED = YES;",
        "CODE_SIGNING_REQUIRED = YES;",
        "CODE_SIGN_STYLE = Manual;",
        "CURRENT_PROJECT_VERSION = 2;",
        f'DEVELOPMENT_TEAM = "{DEVELOPMENT_TEAM}";',
        "GENERATE_INFOPLIST_FILE = NO;",
        "INFOPLIST_FILE = 13-toilet-timer/ToiletTimerLiveActivityInfo.plist;",
        "IPHONEOS_DEPLOYMENT_TARGET = 17.0;",
        'LD_RUNPATH_SEARCH_PATHS = "$(inherited) @executable_path/Frameworks @executable_path/../../Frameworks";',
        "MARKETING_VERSION = 1.0;",
        "PRODUCT_BUNDLE_IDENTIFIER = corp.unecessary.app13toilettimer.liveactivity;",
        'PROVISIONING_PROFILE_SPECIFIER = "Unnecessary Apps Store 13 Live Activity";',
        'PRODUCT_NAME = "$(TARGET_NAME)";',
        "SDKROOT = iphoneos;",
        "SKIP_INSTALL = YES;",
        'SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";',
        "SWIFT_VERSION = 5.0;",
        'TARGETED_DEVICE_FAMILY = "1,2";',
    ])


live_activity_debug = add(
    "config/ToiletTimerLiveActivityExtension/debug",
    f"XCBuildConfiguration = {{ isa = XCBuildConfiguration; buildSettings = {{ {live_activity_settings()} }}; name = Debug; }};",
)
live_activity_release = add(
    "config/ToiletTimerLiveActivityExtension/release",
    f"XCBuildConfiguration = {{ isa = XCBuildConfiguration; buildSettings = {{ {live_activity_settings()} }}; name = Release; }};",
)
live_activity_config_list = add(
    "config/ToiletTimerLiveActivityExtension/list",
    f"XCConfigurationList = {{ isa = XCConfigurationList; buildConfigurations = ({live_activity_debug}, {live_activity_release}); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; }};",
)
live_activity_target = add(
    "target/ToiletTimerLiveActivityExtension",
    f"PBXNativeTarget = {{ isa = PBXNativeTarget; buildConfigurationList = {live_activity_config_list}; buildPhases = ({live_activity_sources_phase}, {live_activity_frameworks_phase}, {live_activity_resources_phase}); buildRules = (); dependencies = (); name = ToiletTimerLiveActivityExtension; productName = ToiletTimerLiveActivityExtension; productReference = {live_activity_product}; productType = \"com.apple.product-type.app-extension\"; }};",
)
app_target_ids.append(live_activity_target)


for target_name, slug in APPS:
    all_source_paths = sorted(p.name for p in (ROOT / slug).glob("*.swift"))
    source_paths = [
        name for name in all_source_paths
        if name not in APP_EXTENSION_ONLY_SOURCES.get(target_name, set())
    ]
    source_refs = [file_ref(f"{slug}/{name}", name) for name in source_paths]
    group_source_refs = [file_ref(f"{slug}/{name}", name) for name in all_source_paths]
    resource_refs = [file_ref(f"{slug}/Assets.xcassets", "Assets.xcassets", "folder.assetcatalog")]
    privacy_manifest = ROOT / slug / "PrivacyInfo.xcprivacy"
    uses_user_defaults = any(
        "@AppStorage" in source.read_text(encoding="utf-8") or "UserDefaults" in source.read_text(encoding="utf-8")
        for source in (ROOT / slug).glob("*.swift")
    )
    if privacy_manifest.exists():
        resource_refs.append(file_ref(f"{slug}/PrivacyInfo.xcprivacy", "PrivacyInfo.xcprivacy", "text.plist.xml"))
    elif uses_user_defaults:
        resource_refs.append(file_ref(f"{slug}/shared/PrivacyInfo.xcprivacy", "../config/PrivacyInfo.xcprivacy", "text.plist.xml"))
    else:
        resource_refs.append(file_ref(
            f"{slug}/shared/no-required-reasons/PrivacyInfo.xcprivacy",
            "../config/no-required-reasons/PrivacyInfo.xcprivacy",
            "text.plist.xml",
        ))
    group_refs = group_source_refs + resource_refs
    if target_name in HEALTHKIT_CONFIG:
        entitlements_path = HEALTHKIT_CONFIG[target_name][0]
        group_refs.append(file_ref(entitlements_path, f"../{entitlements_path}", "text.plist.entitlements"))
    group = add(
        f"group/{slug}",
        "PBXGroup = {\n\t\tisa = PBXGroup;\n\t\tchildren = (\n\t\t\t%s\n\t\t);\n\t\tpath = %s;\n\t\tsourceTree = \"<group>\";\n\t};" % ("\n\t\t\t".join(x + "," for x in group_refs), slug),
    )
    app_groups.append(group)
    source_builds = []
    for ref in source_refs:
        source_builds.append(add(f"build/{target_name}/{ref}", f"PBXBuildFile = {{ isa = PBXBuildFile; fileRef = {ref}; }};"))
    resource_builds = [
        add(f"build/{target_name}/{ref}", f"PBXBuildFile = {{ isa = PBXBuildFile; fileRef = {ref}; }};")
        for ref in resource_refs
    ]
    link_build = add(f"build/{target_name}/DumbKit", f"PBXBuildFile = {{ isa = PBXBuildFile; fileRef = {library_product}; }};")
    sources_phase = add(
        f"phase/{target_name}/sources",
        f"PBXSourcesBuildPhase = {{ isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = ({', '.join(x + ',' for x in source_builds)}); runOnlyForDeploymentPostprocessing = 0; }};",
    )
    frameworks_phase = add(
        f"phase/{target_name}/frameworks",
        f"PBXFrameworksBuildPhase = {{ isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = ({link_build},); runOnlyForDeploymentPostprocessing = 0; }};",
    )
    resources_phase = add(f"phase/{target_name}/resources", f"PBXResourcesBuildPhase = {{ isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = ({', '.join(x + ',' for x in resource_builds)}); runOnlyForDeploymentPostprocessing = 0; }};")
    product = file_ref(f"product/{target_name}", f"{target_name}.app", "wrapper.application")
    products_group_children.append(product)
    debug = add(f"config/{target_name}/debug", f"XCBuildConfiguration = {{ isa = XCBuildConfiguration; buildSettings = {{ {app_settings(target_name, slug)} }}; name = Debug; }};")
    release = add(f"config/{target_name}/release", f"XCBuildConfiguration = {{ isa = XCBuildConfiguration; buildSettings = {{ {app_settings(target_name, slug)} }}; name = Release; }};")
    config_list = add(f"config/{target_name}/list", f"XCConfigurationList = {{ isa = XCConfigurationList; buildConfigurations = ({debug}, {release}); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; }};")
    proxy = add(f"proxy/{target_name}", f"PBXContainerItemProxy = {{ isa = PBXContainerItemProxy; containerPortal = PROJECT; proxyType = 1; remoteGlobalID = {library_target}; remoteInfo = DumbKit; }};")
    dependency = add(f"dependency/{target_name}", f"PBXTargetDependency = {{ isa = PBXTargetDependency; target = {library_target}; targetProxy = {proxy}; }};")
    build_phases = [sources_phase, frameworks_phase, resources_phase]
    dependencies = [dependency]
    if target_name == "App13ToiletTimer":
        live_activity_embed_build = add(
            "build/App13ToiletTimer/embed-live-activity",
            f"PBXBuildFile = {{ isa = PBXBuildFile; fileRef = {live_activity_product}; settings = {{ ATTRIBUTES = (RemoveHeadersOnCopy,); }}; }};",
        )
        live_activity_embed_phase = add(
            "phase/App13ToiletTimer/embed-live-activity",
            f"PBXCopyFilesBuildPhase = {{ isa = PBXCopyFilesBuildPhase; buildActionMask = 2147483647; dstPath = \"\"; dstSubfolderSpec = 13; files = ({live_activity_embed_build},); name = \"Embed App Extensions\"; runOnlyForDeploymentPostprocessing = 0; }};",
        )
        live_activity_proxy = add(
            "proxy/App13ToiletTimer/live-activity",
            f"PBXContainerItemProxy = {{ isa = PBXContainerItemProxy; containerPortal = PROJECT; proxyType = 1; remoteGlobalID = {live_activity_target}; remoteInfo = ToiletTimerLiveActivityExtension; }};",
        )
        live_activity_dependency = add(
            "dependency/App13ToiletTimer/live-activity",
            f"PBXTargetDependency = {{ isa = PBXTargetDependency; target = {live_activity_target}; targetProxy = {live_activity_proxy}; }};",
        )
        build_phases.append(live_activity_embed_phase)
        dependencies.append(live_activity_dependency)
    target_id = add(
        f"target/{target_name}",
        f"PBXNativeTarget = {{ isa = PBXNativeTarget; buildConfigurationList = {config_list}; buildPhases = ({', '.join(x + ',' for x in build_phases)}); buildRules = (); dependencies = ({', '.join(x + ',' for x in dependencies)}); name = {target_name}; productName = {target_name}; productReference = {product}; productType = \"com.apple.product-type.application\"; }};",
    )
    app_target_ids.append(target_id)
    app_target_by_name[target_name] = target_id

pilot_ui_test_source = file_ref(
    "tests/App03DoNotTextThemUITests.swift",
    "App03DoNotTextThemUITests.swift",
)
test_group = add(
    "group/tests",
    "PBXGroup = {\n\t\tisa = PBXGroup;\n\t\tchildren = (%s,);\n\t\tpath = tests;\n\t\tsourceTree = \"<group>\";\n\t};" % pilot_ui_test_source,
)
xc_test_framework = file_ref(
    "framework/XCTest",
    "XCTest.framework",
    "wrapper.framework",
)
objects[xc_test_framework] = objects[xc_test_framework].replace(
    "path = XCTest.framework;",
    "name = XCTest.framework;\n\t\tpath = System/Library/Frameworks/XCTest.framework;",
).replace(
    "sourceTree = \"<group>\";",
    "sourceTree = SDKROOT;",
)
pilot_ui_test_source_build = add(
    "build/App03DoNotTextThemUITests/source",
    f"PBXBuildFile = {{ isa = PBXBuildFile; fileRef = {pilot_ui_test_source}; }};",
)
xc_test_framework_build = add(
    "build/App03DoNotTextThemUITests/XCTest",
    f"PBXBuildFile = {{ isa = PBXBuildFile; fileRef = {xc_test_framework}; }};",
)
pilot_ui_test_sources_phase = add(
    "phase/App03DoNotTextThemUITests/sources",
    f"PBXSourcesBuildPhase = {{ isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = ({pilot_ui_test_source_build},); runOnlyForDeploymentPostprocessing = 0; }};",
)
pilot_ui_test_frameworks_phase = add(
    "phase/App03DoNotTextThemUITests/frameworks",
    f"PBXFrameworksBuildPhase = {{ isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = ({xc_test_framework_build},); runOnlyForDeploymentPostprocessing = 0; }};",
)
pilot_ui_test_resources_phase = add(
    "phase/App03DoNotTextThemUITests/resources",
    "PBXResourcesBuildPhase = { isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; };",
)
pilot_ui_test_product = file_ref(
    "product/App03DoNotTextThemUITests",
    "App03DoNotTextThemUITests.xctest",
    "wrapper.cfbundle",
)
products_group_children.append(pilot_ui_test_product)

def ui_test_settings() -> str:
    return "\n".join([
        "CLANG_ENABLE_MODULES = YES;",
        "CODE_SIGNING_ALLOWED = NO;",
        "CODE_SIGNING_REQUIRED = NO;",
        "CODE_SIGN_STYLE = Automatic;",
        "CURRENT_PROJECT_VERSION = 1;",
        "DEVELOPMENT_TEAM = \"\";",
        "GENERATE_INFOPLIST_FILE = YES;",
        "IPHONEOS_DEPLOYMENT_TARGET = 17.0;",
        "PRODUCT_BUNDLE_IDENTIFIER = corp.unecessary.app03donottextthem.uitests;",
        "PRODUCT_NAME = \"$(TARGET_NAME)\";",
        "SDKROOT = iphoneos;",
        "SUPPORTED_PLATFORMS = \"iphoneos iphonesimulator\";",
        "SWIFT_VERSION = 5.0;",
        "TARGETED_DEVICE_FAMILY = \"1,2\";",
        "TEST_TARGET_NAME = App03DoNotTextThem;",
    ])

pilot_ui_test_debug = add(
    "config/App03DoNotTextThemUITests/debug",
    f"XCBuildConfiguration = {{ isa = XCBuildConfiguration; buildSettings = {{ {ui_test_settings()} }}; name = Debug; }};",
)
pilot_ui_test_release = add(
    "config/App03DoNotTextThemUITests/release",
    f"XCBuildConfiguration = {{ isa = XCBuildConfiguration; buildSettings = {{ {ui_test_settings()} }}; name = Release; }};",
)
pilot_ui_test_config_list = add(
    "config/App03DoNotTextThemUITests/list",
    f"XCConfigurationList = {{ isa = XCConfigurationList; buildConfigurations = ({pilot_ui_test_debug}, {pilot_ui_test_release}); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; }};",
)
pilot_ui_test_proxy = add(
    "proxy/App03DoNotTextThemUITests",
    f"PBXContainerItemProxy = {{ isa = PBXContainerItemProxy; containerPortal = PROJECT; proxyType = 1; remoteGlobalID = {app_target_by_name['App03DoNotTextThem']}; remoteInfo = App03DoNotTextThem; }};",
)
pilot_ui_test_dependency = add(
    "dependency/App03DoNotTextThemUITests",
    f"PBXTargetDependency = {{ isa = PBXTargetDependency; target = {app_target_by_name['App03DoNotTextThem']}; targetProxy = {pilot_ui_test_proxy}; }};",
)
pilot_ui_test_target = add(
    "target/App03DoNotTextThemUITests",
    f"PBXNativeTarget = {{ isa = PBXNativeTarget; buildConfigurationList = {pilot_ui_test_config_list}; buildPhases = ({pilot_ui_test_sources_phase}, {pilot_ui_test_frameworks_phase}, {pilot_ui_test_resources_phase}); buildRules = (); dependencies = ({pilot_ui_test_dependency}); name = App03DoNotTextThemUITests; productName = App03DoNotTextThemUITests; productReference = {pilot_ui_test_product}; productType = \"com.apple.product-type.bundle.ui-testing\"; }};",
)
app_target_ids.append(pilot_ui_test_target)

products_group = add("group/products", f"PBXGroup = {{ isa = PBXGroup; children = ({', '.join(x + ',' for x in products_group_children)}); name = Products; sourceTree = \"<group>\"; }};")
main_group = add("group/main", f"PBXGroup = {{ isa = PBXGroup; children = ({shared_group}, {products_group}, {test_group}, {', '.join(x + ',' for x in app_groups)}); sourceTree = \"<group>\"; }};")
project_id = add(
    "project/root",
    f"PBXProject = {{ isa = PBXProject; buildConfigurationList = {project_config_list}; compatibilityVersion = \"Xcode 15.0\"; developmentRegion = en; hasScannedForEncodings = 0; knownRegions = (en, Base,); mainGroup = {main_group}; productRefGroup = {products_group}; projectDirPath = \"\"; projectRoot = \"\"; targets = ({library_target}, {', '.join(x + ',' for x in app_target_ids)}); }};",
)

for key, value in list(objects.items()):
    objects[key] = value.replace("containerPortal = PROJECT", f"containerPortal = {project_id}")

PROJECT_DIR.mkdir(exist_ok=True)
with PROJECT_FILE.open("w", encoding="utf-8") as handle:
    handle.write("// !$*UTF8*$!\n{\n\tarchiveVersion = 1;\n\tobjectVersion = 56;\n\tobjects = {\n")
    for ident in sorted(objects):
        normalized = objects[ident].replace(",,", ",")
        handle.write(f"\t\t{ident} = {normalized}\n")
    handle.write("\t};\n\trootObject = %s;\n}\n" % project_id)

scheme_dir = PROJECT_DIR / "xcshareddata" / "xcschemes"
scheme_dir.mkdir(parents=True, exist_ok=True)

def scheme_buildable(blueprint_id: str, name: str, product_name: str) -> str:
    return f'''<BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{blueprint_id}"
               BuildableName = "{product_name}"
               BlueprintName = "{name}"
               ReferencedContainer = "container:UnnecessaryApps.xcodeproj">
            </BuildableReference>'''

def write_focused_ui_test_scheme(
    scheme_name: str,
    app_names: list[str],
    test_names: list[str],
) -> None:
    app_build_entries = "\n".join(
        f'''         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "NO"
            buildForArchiving = "NO"
            buildForAnalyzing = "YES">
            {scheme_buildable(app_target_by_name[name], name, f"{name}.app")}
         </BuildActionEntry>'''
        for name in app_names
    )
    ui_test_buildable = scheme_buildable(
        pilot_ui_test_target,
        "App03DoNotTextThemUITests",
        "App03DoNotTextThemUITests.xctest",
    )
    selected_tests = "\n".join(
        f'               <Test Identifier = "App03DoNotTextThemUITests/{name}()"/>'
        for name in test_names
    )
    scheme = f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="2620" version="1.7">
   <BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting="YES"
            buildForRunning="NO"
            buildForProfiling="NO"
            buildForArchiving="NO"
            buildForAnalyzing="YES">
            {ui_test_buildable}
         </BuildActionEntry>
{app_build_entries}
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration="Debug"
      selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv="YES">
      <Testables>
         <TestableReference skipped="NO">
            {ui_test_buildable}
            <SelectedTests>
{selected_tests}
            </SelectedTests>
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration="Debug"
      selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle="0"
      useCustomWorkingDirectory="NO"
      ignoresPersistentStateOnLaunch="NO"
      debugDocumentVersioning="YES"
      debugServiceExtension="internal"
      allowLocationSimulation="YES"/>
   <ProfileAction buildConfiguration="Release" shouldUseLaunchSchemeArgsEnv="YES"/>
   <AnalyzeAction buildConfiguration="Debug"/>
   <ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="NO"/>
</Scheme>
'''
    (scheme_dir / f"{scheme_name}.xcscheme").write_text(scheme, encoding="utf-8")

write_focused_ui_test_scheme(
    "MapAppsUITests",
    ["App02BathroomMap", "App23QuietCafe", "App29BenchReviews"],
    [
        "testBathroomMapSavesPersistsAndClearsWithoutLocation",
        "testBathroomMapSearchReachesAUsefulOutcome",
        "testQuietCafeSavesPersistsAndClearsWithoutLocation",
        "testQuietCafeSearchReachesAUsefulOutcome",
        "testBenchReviewSavesPersistsAndClears",
    ],
)
write_focused_ui_test_scheme(
    "GenerativeAppsUITests",
    ["App19MedievalAdvice", "App30ApologyDraft"],
    [
        "testPeasantAdviceAnswersAndResets",
        "testApologyGeneratorDraftsCopiesAndClears",
    ],
)
write_focused_ui_test_scheme(
    "ChairFinderUITests",
    ["App01ChairFinder"],
    ["testChairFinderInspectsAndResets"],
)
write_focused_ui_test_scheme(
    "TinyMuseumUITests",
    ["App27TinyMuseum"],
    ["testTinyMuseumOpensAndResets"],
)
write_focused_ui_test_scheme(
    "RealEmailUITests",
    ["App20RealEmail"],
    ["testRealEmailAnalyzesAndClears"],
)
write_focused_ui_test_scheme(
    "MemoryLogUITests",
    ["App10WhatWasIDoing"],
    ["testWhatWasIDoingRecordsAndPersists"],
)
write_focused_ui_test_scheme(
    "GratitudeUITests",
    ["App18TinyGratitude"],
    ["testTinyGratitudeArchivesAndClears"],
)
write_focused_ui_test_scheme(
    "OverthinkingUITests",
    ["App28OverthinkingBoard"],
    ["testOverthinkingBoardReachesAndClearsConclusion"],
)
write_focused_ui_test_scheme(
    "HydrationUITests",
    ["App43HydrationNarc"],
    ["testHydrationNarcLogsAndResets"],
)
write_focused_ui_test_scheme(
    "HealthAppsUITests",
    [
        "App36StepDebt",
        "App37SleepAlibi",
        "App39WorkoutExcuse",
        "App40HealthHoroscope",
        "App41RecoveryGoblin",
        "App43HydrationNarc",
        "App44RestDayPolice",
    ],
    [
        "testStepDebtCalculatesAndResets",
        "testSleepAlibiGeneratesAndResets",
        "testWorkoutExcuseDetectsAndResets",
        "testHealthHoroscopeConsultsAndResets",
        "testRecoveryGoblinAnswersAndResets",
        "testHydrationNarcLogsAndResets",
        "testRestDayPoliceIssuesAndResets",
    ],
)
write_focused_ui_test_scheme(
    "StepDebtUITests",
    ["App36StepDebt"],
    ["testStepDebtCalculatesAndResets"],
)
write_focused_ui_test_scheme(
    "ToiletTimerUITests",
    ["App13ToiletTimer"],
    ["testToiletTimerAssessesAndResets"],
)
write_focused_ui_test_scheme(
    "MeetingBingoUITests",
    ["App17MeetingBingo"],
    ["testMeetingBingoMarksAndPersists"],
)
write_focused_ui_test_scheme(
    "SnackRouletteUITests",
    ["App22SnackRoulette"],
    ["testSnackRouletteSpinsAndClears"],
)
write_focused_ui_test_scheme(
    "PunctualityUITests",
    ["App11AmIEarly"],
    ["testAmIEarlyCalculatesAndResets"],
)
write_focused_ui_test_scheme(
    "EpisodeForecastUITests",
    ["App14OneMoreEpisode"],
    ["testEpisodeForecastCalculatesAndResets"],
)
write_focused_ui_test_scheme(
    "ClosetRulingUITests",
    ["App15CanIWearThisAgain"],
    ["testClosetRulingAsksAndResets"],
)
write_focused_ui_test_scheme(
    "MicrowaveConversionUITests",
    ["App16MicrowaveSommelier"],
    ["testMicrowaveSommelierPairsAndResets"],
)
write_focused_ui_test_scheme(
    "SocialBatteryUITests",
    ["App04SocialBatteryReceipt"],
    ["testSocialBatteryPrintsAndResets"],
)
write_focused_ui_test_scheme(
    "FridgeInventoryUITests",
    ["App05FridgeWitness"],
    ["testFridgeWitnessInterrogatesAndClears"],
)
write_focused_ui_test_scheme(
    "PurchaseLedgerUITests",
    ["App06ReceiptEmotionalDamage"],
    ["testReceiptDamageReportsAndClears"],
)
write_focused_ui_test_scheme(
    "SockDocketUITests",
    ["App07SockTribunal"],
    ["testSockTribunalTracksAndResolvesCases"],
)
write_focused_ui_test_scheme(
    "PlantCareUITests",
    ["App08PlantCourt"],
    ["testPlantCourtTracksWateringAndEdits"],
)
write_focused_ui_test_scheme(
    "LaundryQueueUITests",
    ["App09LaundryMountain"],
    ["testLaundryMountainTracksCompleteBatchLifecycle"],
)
write_focused_ui_test_scheme(
    "QueueTrackerUITests",
    ["App33QueuePersonality"],
    ["testQueueTrackerMeasuresProgressAndHistory"],
)
write_focused_ui_test_scheme(
    "LastSliceFairnessUITests",
    ["App32LastSlice"],
    ["testLastSliceRotatesFairlyAndPersistsHistory"],
)
write_focused_ui_test_scheme(
    "DoorIncidentLogUITests",
    ["App35DoorWasPush"],
    ["testDoorIncidentLogPersistsEditsAndErases"],
)
write_focused_ui_test_scheme(
    "VisionComedyUITests",
    ["App12PigeonOrSeagull", "App24DogNameGuesser"],
    ["testPigeonClassifierIdentifiesAndResets", "testDogNameGuesserPresentsAndResets"],
)
write_focused_ui_test_scheme(
    "WalkingMeetingSessionUITests",
    ["App42WalkingMeeting"],
    ["testWalkingMeetingTracksAgendaNotesAndOutcomes"],
)

print(f"generated {PROJECT_FILE} with {len(APPS)} app targets")
