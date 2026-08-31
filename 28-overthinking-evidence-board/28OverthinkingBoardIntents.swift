import AppIntents
import DumbKit

struct 28OverthinkingBoardIntent: AppIntent {
    static var title: LocalizedStringResource = "Open evidence board"
    static var description = IntentDescription("Open open evidence board in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "open")
        return .result()
    }
}

struct App28OverthinkingBoardShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 28OverthinkingBoardIntent(),
            phrases: [
                "Open evidence board in \(.applicationName)",
                "Open evidence board with \(.applicationName)"
            ],
            shortTitle: "Open",
            systemImageName: "pin.fill"
        )
    }
}
