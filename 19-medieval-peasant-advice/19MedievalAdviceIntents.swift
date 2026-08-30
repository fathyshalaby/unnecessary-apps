import AppIntents
import DumbKit

struct 19MedievalAdviceIntent: AppIntent {
    static var title: LocalizedStringResource = "Ask the peasant"
    static var description = IntentDescription("Open ask the peasant in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "ask")
        return .result()
    }
}

struct App19MedievalAdviceShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 19MedievalAdviceIntent(),
            phrases: [
                "Ask the peasant in \(.applicationName)",
                "Ask the peasant with \(.applicationName)"
            ],
            shortTitle: "Ask",
            systemImageName: "person.fill.questionmark"
        )
    }
}
