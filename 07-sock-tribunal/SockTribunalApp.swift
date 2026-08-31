import SwiftUI
import DumbKit

@main
struct SockTribunalApp: App {
    var body: some Scene { WindowGroup { SockTribunalView().dumbNativeEntry(scheme: "app07socktribunal") { _, _ in } } }
}
