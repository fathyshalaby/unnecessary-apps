import AppIntents
import DumbKit

struct 07SockTribunalIntent: AppIntent {
    static var title: LocalizedStringResource = "Open sock tribunal"
    static var description = IntentDescription("Open open sock tribunal in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "open")
        return .result()
    }
}

struct App07SockTribunalShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 07SockTribunalIntent(),
            phrases: [
                "Open sock tribunal in \(.applicationName)",
                "Open sock tribunal with \(.applicationName)"
            ],
            shortTitle: "Open",
            systemImageName: "wind"
        )
    }
}
