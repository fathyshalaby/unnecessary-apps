import AppIntents
import DumbKit

struct 12PigeonOrSeagullIntent: AppIntent {
    static var title: LocalizedStringResource = "Identify the bird"
    static var description = IntentDescription("Open identify the bird in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "identify")
        return .result()
    }
}

struct App12PigeonOrSeagullShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 12PigeonOrSeagullIntent(),
            phrases: [
                "Identify the bird in \(.applicationName)",
                "Identify the bird with \(.applicationName)"
            ],
            shortTitle: "Identify",
            systemImageName: "camera.fill"
        )
    }
}
