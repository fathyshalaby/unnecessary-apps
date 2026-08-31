import AppIntents
import DumbKit

struct 21VibeMeterIntent: AppIntent {
    static var title: LocalizedStringResource = "Read the vibe"
    static var description = IntentDescription("Open read the vibe in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "read")
        return .result()
    }
}

struct App21VibeMeterShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 21VibeMeterIntent(),
            phrases: [
                "Read the vibe in \(.applicationName)",
                "Read the vibe with \(.applicationName)"
            ],
            shortTitle: "Read",
            systemImageName: "waveform.path.ecg"
        )
    }
}
