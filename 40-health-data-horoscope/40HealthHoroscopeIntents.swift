import AppIntents
import DumbKit

struct 40HealthHoroscopeIntent: AppIntent {
    static var title: LocalizedStringResource = "Read today's horoscope"
    static var description = IntentDescription("Open read today's horoscope in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "read")
        return .result()
    }
}

struct App40HealthHoroscopeShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 40HealthHoroscopeIntent(),
            phrases: [
                "Read today's horoscope in \(.applicationName)",
                "Read today's horoscope with \(.applicationName)"
            ],
            shortTitle: "Read",
            systemImageName: "sparkles"
        )
    }
}
