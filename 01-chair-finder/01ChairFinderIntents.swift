import AppIntents
import DumbKit

struct 01ChairFinderIntent: AppIntent {
    static var title: LocalizedStringResource = "Rank the chairs"
    static var description = IntentDescription("Open rank the chairs in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "rank")
        return .result()
    }
}

struct App01ChairFinderShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 01ChairFinderIntent(),
            phrases: [
                "Rank the chairs in \(.applicationName)",
                "Rank the chairs with \(.applicationName)"
            ],
            shortTitle: "Rank",
            systemImageName: "chair.fill"
        )
    }
}
