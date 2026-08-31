import AppIntents
import DumbKit

struct 35DoorWasPushIntent: AppIntent {
    static var title: LocalizedStringResource = "Settle push or pull"
    static var description = IntentDescription("Open settle push or pull in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "settle")
        return .result()
    }
}

struct App35DoorWasPushShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 35DoorWasPushIntent(),
            phrases: [
                "Settle push or pull in \(.applicationName)",
                "Settle push or pull with \(.applicationName)"
            ],
            shortTitle: "Settle",
            systemImageName: "door.left.hand.open"
        )
    }
}
