import AppIntents
import DumbKit

struct 16MicrowaveSommelierIntent: AppIntent {
    static var title: LocalizedStringResource = "Convert microwave time"
    static var description = IntentDescription("Open convert microwave time in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "convert")
        return .result()
    }
}

struct App16MicrowaveSommelierShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 16MicrowaveSommelierIntent(),
            phrases: [
                "Convert microwave time in \(.applicationName)",
                "Convert microwave time with \(.applicationName)"
            ],
            shortTitle: "Convert",
            systemImageName: "timer"
        )
    }
}
