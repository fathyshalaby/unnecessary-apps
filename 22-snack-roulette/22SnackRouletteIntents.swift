import AppIntents
import DumbKit

struct 22SnackRouletteIntent: AppIntent {
    static var title: LocalizedStringResource = "Spin snack roulette"
    static var description = IntentDescription("Open spin snack roulette in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "spin")
        return .result()
    }
}

struct App22SnackRouletteShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 22SnackRouletteIntent(),
            phrases: [
                "Spin snack roulette in \(.applicationName)",
                "Spin snack roulette with \(.applicationName)"
            ],
            shortTitle: "Spin",
            systemImageName: "dice.fill"
        )
    }
}
