import AppIntents
import DumbKit

struct 04SocialBatteryReceiptIntent: AppIntent {
    static var title: LocalizedStringResource = "Print social battery receipt"
    static var description = IntentDescription("Open print social battery receipt in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "print")
        return .result()
    }
}

struct App04SocialBatteryReceiptShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 04SocialBatteryReceiptIntent(),
            phrases: [
                "Print social battery receipt in \(.applicationName)",
                "Print social battery receipt with \(.applicationName)"
            ],
            shortTitle: "Print",
            systemImageName: "battery.100.bolt"
        )
    }
}
