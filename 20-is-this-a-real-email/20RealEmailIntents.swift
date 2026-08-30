import AppIntents
import DumbKit

struct 20RealEmailIntent: AppIntent {
    static var title: LocalizedStringResource = "Analyze this email"
    static var description = IntentDescription("Open analyze this email in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "analyze")
        return .result()
    }
}

struct App20RealEmailShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 20RealEmailIntent(),
            phrases: [
                "Analyze this email in \(.applicationName)",
                "Analyze this email with \(.applicationName)"
            ],
            shortTitle: "Analyze",
            systemImageName: "envelope.fill"
        )
    }
}
