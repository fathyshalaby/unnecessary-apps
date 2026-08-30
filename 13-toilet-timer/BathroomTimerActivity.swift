import ActivityKit
import Foundation

struct BathroomTimerAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var status: String
    }

    let startedAt: Date
    let sessionID: UUID
}
