import AppIntents
import DumbKit

struct 44RestDayPoliceIntent: AppIntent {
    static var title: LocalizedStringResource = "Check rest-day streak"
    static var description = IntentDescription("Open check rest-day streak in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "check")
        return .result()
    }
}

struct App44RestDayPoliceShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 44RestDayPoliceIntent(),
            phrases: [
                "Check rest-day streak in \(.applicationName)",
                "Check rest-day streak with \(.applicationName)"
            ],
            shortTitle: "Check",
            systemImageName: "figure.walk.circle"
        )
    }
}
