import AppIntents
import DumbKit

struct StampStepDebtIntent: AppIntent {
    static var title: LocalizedStringResource = "Stamp today's invoice"
    static var description = IntentDescription("Open Step Debt and stamp today's fictional step invoice.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "stamp")
        return .result()
    }
}

struct StepDebtShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StampStepDebtIntent(),
            phrases: [
                "Stamp my step debt in \(.applicationName)",
                "Check step debt with \(.applicationName)",
                "Open step invoice with \(.applicationName)"
            ],
            shortTitle: "Stamp invoice",
            systemImageName: "figure.walk"
        )
    }
}
