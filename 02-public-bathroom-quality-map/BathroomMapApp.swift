import SwiftUI
import DumbKit

@main
struct BathroomMapApp: App {
    var body: some Scene { WindowGroup { BathroomMapView().dumbNativeEntry(scheme: "app02bathroommap") { _, _ in } } }
}
