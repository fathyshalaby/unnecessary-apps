import AppIntents
import DumbKit

struct 27TinyMuseumIntent: AppIntent {
    static var title: LocalizedStringResource = "Open tiny museum"
    static var description = IntentDescription("Open open tiny museum in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "open")
        return .result()
    }
}

struct App27TinyMuseumShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 27TinyMuseumIntent(),
            phrases: [
                "Open tiny museum in \(.applicationName)",
                "Open tiny museum with \(.applicationName)"
            ],
            shortTitle: "Open",
            systemImageName: "building.columns.fill"
        )
    }
}
