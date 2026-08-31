import SwiftUI
import DumbKit

@main
struct FridgeWitnessApp: App {
    var body: some Scene { WindowGroup { FridgeWitnessView().dumbNativeEntry(scheme: "app05fridgewitness") { _, _ in } } }
}
