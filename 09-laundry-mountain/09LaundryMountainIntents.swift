import AppIntents
import DumbKit

struct 09LaundryMountainIntent: AppIntent {
    static var title: LocalizedStringResource = "Check laundry mountain"
    static var description = IntentDescription("Open check laundry mountain in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "open")
        return .result()
    }
}

struct App09LaundryMountainShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 09LaundryMountainIntent(),
            phrases: [
                "Check laundry mountain in \(.applicationName)",
                "Check laundry mountain with \(.applicationName)"
            ],
            shortTitle: "Check",
            systemImageName: "tshirt.fill"
        )
    }
}
