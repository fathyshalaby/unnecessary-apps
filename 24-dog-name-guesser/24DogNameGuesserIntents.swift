import AppIntents
import DumbKit

struct 24DogNameGuesserIntent: AppIntent {
    static var title: LocalizedStringResource = "Guess the dog name"
    static var description = IntentDescription("Open guess the dog name in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "guess")
        return .result()
    }
}

struct App24DogNameGuesserShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 24DogNameGuesserIntent(),
            phrases: [
                "Guess the dog name in \(.applicationName)",
                "Guess the dog name with \(.applicationName)"
            ],
            shortTitle: "Guess",
            systemImageName: "pawprint.fill"
        )
    }
}
