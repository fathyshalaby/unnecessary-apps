import AppIntents
import DumbKit

struct 37SleepAlibiIntent: AppIntent {
    static var title: LocalizedStringResource = "Check sleep alibi"
    static var description = IntentDescription("Open check sleep alibi in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "check")
        return .result()
    }
}

struct App37SleepAlibiShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 37SleepAlibiIntent(),
            phrases: [
                "Check sleep alibi in \(.applicationName)",
                "Check sleep alibi with \(.applicationName)"
            ],
            shortTitle: "Check",
            systemImageName: "bed.double.fill"
        )
    }
}
