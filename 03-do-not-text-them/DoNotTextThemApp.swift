import SwiftUI
import DumbKit

@main
struct DoNotTextThemApp: App {
    init() {
        // Keep UI-test state deterministic without changing normal user behavior.
        if ProcessInfo.processInfo.arguments.contains("-uiTestReset") {
            UserDefaults.standard.removeObject(forKey: "doNotTextThem.completedInterventions")
            UserDefaults.standard.removeObject(forKey: "doNotTextThem.deletedDrafts")
        }
    }

    var body: some Scene { WindowGroup { DoNotTextThemView() } }
}
