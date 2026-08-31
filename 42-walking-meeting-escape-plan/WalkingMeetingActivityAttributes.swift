import Foundation

struct WalkingMeetingActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var elapsedMinutes: Int
        var status: String
    }

    let meetingTitle: String
    let sessionID: UUID
}
