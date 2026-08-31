import SwiftUI
import DumbKit

@main
struct LaundryMountainApp: App {
    var body: some Scene { WindowGroup { LaundryMountainView().dumbNativeEntry(scheme: "app09laundrymountain") { _, _ in } } }
}
