import AppIntents
import DumbKit

struct 39WorkoutExcuseIntent: AppIntent {
    static var title: LocalizedStringResource = "Judge my excuse"
    static var description = IntentDescription("Open judge my excuse in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "judge")
        return .result()
    }
}

struct App39WorkoutExcuseShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 39WorkoutExcuseIntent(),
            phrases: [
                "Judge my excuse in \(.applicationName)",
                "Judge my excuse with \(.applicationName)"
            ],
            shortTitle: "Judge",
            systemImageName: "figure.run"
        )
    }
}
