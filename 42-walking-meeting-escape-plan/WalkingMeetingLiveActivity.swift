import ActivityKit
import SwiftUI
import WidgetKit

struct WalkingMeetingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WalkingMeetingActivityAttributes.self) { context in
            VStack(alignment: .leading, spacing: 6) {
                Text(context.attributes.meetingTitle)
                    .font(.headline.weight(.black))
                Text("\(context.state.elapsedMinutes) min walking")
                    .font(.title2.weight(.black))
                Text(context.state.status)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(12)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label("\(context.state.elapsedMinutes)m", systemImage: "figure.walk")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Escape walk")
                        .font(.caption.weight(.black))
                }
            } compactLeading: {
                Image(systemName: "figure.walk")
            } compactTrailing: {
                Text("\(context.state.elapsedMinutes)m")
                    .font(.caption2.weight(.black))
            } minimal: {
                Image(systemName: "figure.walk")
            }
        }
    }
}

@main
struct WalkingMeetingLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        WalkingMeetingLiveActivity()
    }
}
