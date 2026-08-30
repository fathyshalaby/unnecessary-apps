import AppIntents
import DumbKit

struct 25WaitingRoomIntent: AppIntent {
    static var title: LocalizedStringResource = "Start waiting room"
    static var description = IntentDescription("Open start waiting room in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "start")
        return .result()
    }
}

struct App25WaitingRoomShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 25WaitingRoomIntent(),
            phrases: [
                "Start waiting room in \(.applicationName)",
                "Start waiting room with \(.applicationName)"
            ],
            shortTitle: "Start",
            systemImageName: "hourglass"
        )
    }
}
