import AppIntents
import DumbKit

struct 23QuietCafeIntent: AppIntent {
    static var title: LocalizedStringResource = "Open café index"
    static var description = IntentDescription("Open open café index in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "open")
        return .result()
    }
}

struct App23QuietCafeShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 23QuietCafeIntent(),
            phrases: [
                "Open café index in \(.applicationName)",
                "Open café index with \(.applicationName)"
            ],
            shortTitle: "Open",
            systemImageName: "cup.and.saucer.fill"
        )
    }
}
