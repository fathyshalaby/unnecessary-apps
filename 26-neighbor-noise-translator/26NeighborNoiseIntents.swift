import AppIntents
import DumbKit

struct 26NeighborNoiseIntent: AppIntent {
    static var title: LocalizedStringResource = "Translate the noise"
    static var description = IntentDescription("Open translate the noise in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "translate")
        return .result()
    }
}

struct App26NeighborNoiseShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 26NeighborNoiseIntent(),
            phrases: [
                "Translate the noise in \(.applicationName)",
                "Translate the noise with \(.applicationName)"
            ],
            shortTitle: "Translate",
            systemImageName: "ear.fill"
        )
    }
}
