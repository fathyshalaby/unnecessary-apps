import AppIntents
import DumbKit

struct 14OneMoreEpisodeIntent: AppIntent {
    static var title: LocalizedStringResource = "Forecast one more episode"
    static var description = IntentDescription("Open forecast one more episode in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "forecast")
        return .result()
    }
}

struct App14OneMoreEpisodeShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 14OneMoreEpisodeIntent(),
            phrases: [
                "Forecast one more episode in \(.applicationName)",
                "Forecast one more episode with \(.applicationName)"
            ],
            shortTitle: "Forecast",
            systemImageName: "tv.fill"
        )
    }
}
