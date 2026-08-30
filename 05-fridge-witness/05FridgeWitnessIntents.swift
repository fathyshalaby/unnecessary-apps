import AppIntents
import DumbKit

struct 05FridgeWitnessIntent: AppIntent {
    static var title: LocalizedStringResource = "Check the fridge"
    static var description = IntentDescription("Open check the fridge in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "open")
        return .result()
    }
}

struct App05FridgeWitnessShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 05FridgeWitnessIntent(),
            phrases: [
                "Check the fridge in \(.applicationName)",
                "Check the fridge with \(.applicationName)"
            ],
            shortTitle: "Check",
            systemImageName: "refrigerator.fill"
        )
    }
}
