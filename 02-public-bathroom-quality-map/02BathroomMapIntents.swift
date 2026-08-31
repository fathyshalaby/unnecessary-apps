import AppIntents
import DumbKit

struct 02BathroomMapIntent: AppIntent {
    static var title: LocalizedStringResource = "Open bathroom map"
    static var description = IntentDescription("Open open bathroom map in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "open")
        return .result()
    }
}

struct App02BathroomMapShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 02BathroomMapIntent(),
            phrases: [
                "Open bathroom map in \(.applicationName)",
                "Open bathroom map with \(.applicationName)"
            ],
            shortTitle: "Open",
            systemImageName: "map.fill"
        )
    }
}
