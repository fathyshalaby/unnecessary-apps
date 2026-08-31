import AppIntents
import DumbKit

struct 08PlantCourtIntent: AppIntent {
    static var title: LocalizedStringResource = "Open plant court"
    static var description = IntentDescription("Open open plant court in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "open")
        return .result()
    }
}

struct App08PlantCourtShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 08PlantCourtIntent(),
            phrases: [
                "Open plant court in \(.applicationName)",
                "Open plant court with \(.applicationName)"
            ],
            shortTitle: "Open",
            systemImageName: "leaf.fill"
        )
    }
}
