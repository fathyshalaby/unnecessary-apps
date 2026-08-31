import AppIntents
import DumbKit

struct 18TinyGratitudeIntent: AppIntent {
    static var title: LocalizedStringResource = "Log tiny gratitude"
    static var description = IntentDescription("Open log tiny gratitude in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "log")
        return .result()
    }
}

struct App18TinyGratitudeShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 18TinyGratitudeIntent(),
            phrases: [
                "Log tiny gratitude in \(.applicationName)",
                "Log tiny gratitude with \(.applicationName)"
            ],
            shortTitle: "Log",
            systemImageName: "heart.fill"
        )
    }
}
