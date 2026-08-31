import AppIntents
import DumbKit

struct 15CanIWearThisAgainIntent: AppIntent {
    static var title: LocalizedStringResource = "Rule on this outfit"
    static var description = IntentDescription("Open rule on this outfit in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "rule")
        return .result()
    }
}

struct App15CanIWearThisAgainShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 15CanIWearThisAgainIntent(),
            phrases: [
                "Rule on this outfit in \(.applicationName)",
                "Rule on this outfit with \(.applicationName)"
            ],
            shortTitle: "Rule",
            systemImageName: "tshirt"
        )
    }
}
