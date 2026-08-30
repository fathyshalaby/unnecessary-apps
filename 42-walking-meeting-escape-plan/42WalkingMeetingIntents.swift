import AppIntents
import DumbKit

struct 42WalkingMeetingIntent: AppIntent {
    static var title: LocalizedStringResource = "Start walking meeting"
    static var description = IntentDescription("Open start walking meeting in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "start")
        return .result()
    }
}

struct App42WalkingMeetingShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 42WalkingMeetingIntent(),
            phrases: [
                "Start walking meeting in \(.applicationName)",
                "Start walking meeting with \(.applicationName)"
            ],
            shortTitle: "Start",
            systemImageName: "figure.walk"
        )
    }
}
