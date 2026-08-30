import AppIntents
import DumbKit

struct 11AmIEarlyIntent: AppIntent {
    static var title: LocalizedStringResource = "Rate my punctuality"
    static var description = IntentDescription("Open rate my punctuality in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "rate")
        return .result()
    }
}

struct App11AmIEarlyShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 11AmIEarlyIntent(),
            phrases: [
                "Rate my punctuality in \(.applicationName)",
                "Rate my punctuality with \(.applicationName)"
            ],
            shortTitle: "Rate",
            systemImageName: "clock.fill"
        )
    }
}
