import AppIntents
import DumbKit

struct DraftApologyIntent: AppIntent {
    static var title: LocalizedStringResource = "Draft an apology"
    static var description = IntentDescription("Open the apology department with an optional tiny crime pre-filled.")
    static var openAppWhenRun = true

    @Parameter(title: "What did you do?")
    var crime: String?

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "draft", payload: crime ?? "")
        return .result()
    }
}

struct ApologyDraftShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: DraftApologyIntent(),
            phrases: [
                "Draft an apology in \(.applicationName)",
                "Write an apology with \(.applicationName)",
                "Apologize with \(.applicationName)"
            ],
            shortTitle: "Draft apology",
            systemImageName: "pencil.and.scribble"
        )
    }
}
