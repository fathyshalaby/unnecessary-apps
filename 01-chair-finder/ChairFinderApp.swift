import SwiftUI
import DumbKit

@main
struct ChairFinderApp: App {
    var body: some Scene { WindowGroup { ChairFinderView().dumbNativeEntry(scheme: "app01chairfinder") { _, _ in } } }
}
