import SwiftUI
import DumbKit

@main
struct PlantCourtApp: App {
    var body: some Scene { WindowGroup { PlantCourtView().dumbNativeEntry(scheme: "app08plantcourt") { _, _ in } } }
}
