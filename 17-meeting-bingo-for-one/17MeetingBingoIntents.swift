import AppIntents
import DumbKit

struct 17MeetingBingoIntent: AppIntent {
    static var title: LocalizedStringResource = "Start meeting bingo"
    static var description = IntentDescription("Open start meeting bingo in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "start")
        return .result()
    }
}

struct App17MeetingBingoShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 17MeetingBingoIntent(),
            phrases: [
                "Start meeting bingo in \(.applicationName)",
                "Start meeting bingo with \(.applicationName)"
            ],
            shortTitle: "Start",
            systemImageName: "square.grid.3x3.fill"
        )
    }
}
