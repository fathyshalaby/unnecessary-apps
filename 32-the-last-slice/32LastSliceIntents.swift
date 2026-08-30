import AppIntents
import DumbKit

struct 32LastSliceIntent: AppIntent {
    static var title: LocalizedStringResource = "Settle last slice"
    static var description = IntentDescription("Open settle last slice in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "settle")
        return .result()
    }
}

struct App32LastSliceShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 32LastSliceIntent(),
            phrases: [
                "Settle last slice in \(.applicationName)",
                "Settle last slice with \(.applicationName)"
            ],
            shortTitle: "Settle",
            systemImageName: "fork.knife"
        )
    }
}
