import AppIntents
import DumbKit

struct StartStallTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "Start stall timer"
    static var description = IntentDescription("Begin a bathroom session with lock-screen timing.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "start")
        return .result()
    }
}

struct ToiletTimerShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartStallTimerIntent(),
            phrases: [
                "Start stall timer in \(.applicationName)",
                "Start bathroom timer with \(.applicationName)",
                "Time my bathroom break with \(.applicationName)"
            ],
            shortTitle: "Start timer",
            systemImageName: "timer"
        )
    }
}
