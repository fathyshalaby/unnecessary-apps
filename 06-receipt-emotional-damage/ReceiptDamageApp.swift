import SwiftUI
import DumbKit

@main
struct ReceiptDamageApp: App {
    var body: some Scene { WindowGroup { ReceiptDamageView().dumbNativeEntry(scheme: "app06receiptemotionaldamage") { _, _ in } } }
}
