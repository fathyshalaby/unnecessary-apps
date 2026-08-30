import SwiftUI
import DumbKit

@main
struct WhatWasIDoingApp: App {
    var body: some Scene { WindowGroup { WhatWasIDoingView().dumbNativeEntry(scheme: "app10whatwasidoing") { _, _ in } } }
}
