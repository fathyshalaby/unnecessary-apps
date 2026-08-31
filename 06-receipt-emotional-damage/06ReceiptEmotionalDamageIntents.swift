import AppIntents
import DumbKit

struct 06ReceiptEmotionalDamageIntent: AppIntent {
    static var title: LocalizedStringResource = "Assess the damage"
    static var description = IntentDescription("Open assess the damage in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "assess")
        return .result()
    }
}

struct App06ReceiptEmotionalDamageShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 06ReceiptEmotionalDamageIntent(),
            phrases: [
                "Assess the damage in \(.applicationName)",
                "Assess the damage with \(.applicationName)"
            ],
            shortTitle: "Assess",
            systemImageName: "doc.text.fill"
        )
    }
}
