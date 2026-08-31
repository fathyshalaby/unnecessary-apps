import AppIntents
import DumbKit

struct LogWaterServingIntent: AppIntent {
    static var title: LocalizedStringResource = "Log one serving"
    static var description = IntentDescription("Add one serving to today's hydration ledger.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "log")
        return .result()
    }
}

struct HydrationNarcShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogWaterServingIntent(),
            phrases: [
                "Log water in \(.applicationName)",
                "Log a serving with \(.applicationName)",
                "Hydrate with \(.applicationName)"
            ],
            shortTitle: "Log serving",
            systemImageName: "drop.fill"
        )
    }
}
