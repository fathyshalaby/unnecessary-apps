import ActivityKit
import SwiftUI
import WidgetKit

struct QueueLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: QueueActivityAttributes.self) { context in
            VStack(alignment: .leading, spacing: 6) {
                Text(context.attributes.queueName)
                    .font(.headline.weight(.black))
                Text("\(context.state.peopleAhead) people ahead")
                    .font(.title2.weight(.black))
                Text(context.state.status)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(12)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label("\(context.state.peopleAhead)", systemImage: "person.3.fill")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.attributes.queueName)
                        .font(.caption.weight(.black))
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.status)
                        .font(.caption2)
                }
            } compactLeading: {
                Image(systemName: "person.3.fill")
            } compactTrailing: {
                Text("\(context.state.peopleAhead)")
                    .font(.caption2.weight(.black))
            } minimal: {
                Image(systemName: "person.3.fill")
            }
        }
    }
}

@main
struct QueueLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        QueueLiveActivity()
    }
}
