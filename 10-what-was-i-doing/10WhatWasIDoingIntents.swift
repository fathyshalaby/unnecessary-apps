import AppIntents
import DumbKit

struct 10WhatWasIDoingIntent: AppIntent {
    static var title: LocalizedStringResource = "Log what I was doing"
    static var description = IntentDescription("Open log what i was doing in the app.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DumbPendingLaunch.queue(action: "log")
        return .result()
    }
}

struct App10WhatWasIDoingShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: 10WhatWasIDoingIntent(),
            phrases: [
                "Log what I was doing in \(.applicationName)",
                "Log what I was doing with \(.applicationName)"
            ],
            shortTitle: "Log",
            systemImageName: "questionmark.circle.fill"
        )
    }
}
