import AppIntents
import DumbKit

struct 31HumanGPSIntent: AppIntent {
    static var title: LocalizedStringResource = "Get human directions"
    static var description = IntentDescription("Open get human directions in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "direct")
        return .result()
    }
}

struct App31HumanGPSShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 31HumanGPSIntent(),
            phrases: [
                "Get human directions in \(.applicationName)",
                "Get human directions with \(.applicationName)"
            ],
            shortTitle: "Get",
            systemImageName: "location.fill"
        )
    }
}
