import Foundation

struct QueueActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var peopleAhead: Int
        var status: String
    }

    let queueName: String
    let sessionID: UUID
}
