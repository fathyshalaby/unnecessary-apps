import AppIntents
import DumbKit

struct StartInterventionIntent: AppIntent {
    static var title: LocalizedStringResource = "Start cool-off"
    static var description = IntentDescription("Start a 10-second intervention before you send the message.")
    static var openAppWhenRun = true

    @Parameter(title: "Draft message")
    var message: String?

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "start", payload: message ?? "")
        return .result()
    }
}

struct DoNotTextThemShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartInterventionIntent(),
            phrases: [
                "Start intervention in \(.applicationName)",
                "Cool off with \(.applicationName)",
                "Do not text them with \(.applicationName)"
            ],
            shortTitle: "Start cool-off",
            systemImageName: "hand.raised.fill"
        )
    }
}
