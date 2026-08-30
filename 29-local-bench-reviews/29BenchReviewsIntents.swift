import AppIntents
import DumbKit

struct 29BenchReviewsIntent: AppIntent {
    static var title: LocalizedStringResource = "Open bench reviews"
    static var description = IntentDescription("Open open bench reviews in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "open")
        return .result()
    }
}

struct App29BenchReviewsShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 29BenchReviewsIntent(),
            phrases: [
                "Open bench reviews in \(.applicationName)",
                "Open bench reviews with \(.applicationName)"
            ],
            shortTitle: "Open",
            systemImageName: "figure.seated.side"
        )
    }
}
