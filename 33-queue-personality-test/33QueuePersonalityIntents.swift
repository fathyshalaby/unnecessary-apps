import AppIntents
import DumbKit

struct 33QueuePersonalityIntent: AppIntent {
    static var title: LocalizedStringResource = "Start queue session"
    static var description = IntentDescription("Open start queue session in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "start")
        return .result()
    }
}

struct App33QueuePersonalityShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 33QueuePersonalityIntent(),
            phrases: [
                "Start queue session in \(.applicationName)",
                "Start queue session with \(.applicationName)"
            ],
            shortTitle: "Start",
            systemImageName: "person.3.sequence.fill"
        )
    }
}
