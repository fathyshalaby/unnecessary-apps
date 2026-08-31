import AppIntents
import DumbKit

struct 34WeatherOutfitIntent: AppIntent {
    static var title: LocalizedStringResource = "Generate outfit defense"
    static var description = IntentDescription("Open generate outfit defense in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "defend")
        return .result()
    }
}

struct App34WeatherOutfitShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 34WeatherOutfitIntent(),
            phrases: [
                "Generate outfit defense in \(.applicationName)",
                "Generate outfit defense with \(.applicationName)"
            ],
            shortTitle: "Generate",
            systemImageName: "cloud.sun.fill"
        )
    }
}
