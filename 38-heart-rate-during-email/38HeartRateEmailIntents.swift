import AppIntents
import DumbKit

struct 38HeartRateEmailIntent: AppIntent {
    static var title: LocalizedStringResource = "Record inbox drama"
    static var description = IntentDescription("Open record inbox drama in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "record")
        return .result()
    }
}

struct App38HeartRateEmailShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 38HeartRateEmailIntent(),
            phrases: [
                "Record inbox drama in \(.applicationName)",
                "Record inbox drama with \(.applicationName)"
            ],
            shortTitle: "Record",
            systemImageName: "heart.fill"
        )
    }
}
