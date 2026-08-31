import AppIntents
import DumbKit

struct 41RecoveryGoblinIntent: AppIntent {
    static var title: LocalizedStringResource = "Check in with goblin"
    static var description = IntentDescription("Open check in with goblin in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "checkin")
        return .result()
    }
}

struct App41RecoveryGoblinShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 41RecoveryGoblinIntent(),
            phrases: [
                "Check in with goblin in \(.applicationName)",
                "Check in with goblin with \(.applicationName)"
            ],
            shortTitle: "Check",
            systemImageName: "figure.cooldown"
        )
    }
}
