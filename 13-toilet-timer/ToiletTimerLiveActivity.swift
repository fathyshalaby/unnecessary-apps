import ActivityKit
import SwiftUI
import WidgetKit

@main
struct ToiletTimerLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        ToiletTimerLiveActivity()
    }
}

struct ToiletTimerLiveActivity: Widget {
    private let warningRed = Color(red: 0.91, green: 0.16, blue: 0.18)

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BathroomTimerAttributes.self) { context in
            HStack(spacing: 14) {
                Image(systemName: "toilet.fill")
                    .font(.title2.weight(.black))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(warningRed, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text("BATHROOM OPS")
                        .font(.caption2.weight(.black))
                        .tracking(1.1)
                        .foregroundStyle(warningRed)
                    Text(timerInterval: context.attributes.startedAt...Date.distantFuture, countsDown: false)
                        .font(.title2.weight(.black))
                        .monospacedDigit()
                    Text("Next paperwork at 5, 10, 15 & 20 min")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .padding(16)
            .activityBackgroundTint(Color(red: 1.0, green: 0.96, blue: 0.90))
            .activitySystemActionForegroundColor(warningRed)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "toilet.fill")
                        .font(.title2.weight(.black))
                        .foregroundStyle(warningRed)
                        .accessibilityHidden(true)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: context.attributes.startedAt...Date.distantFuture, countsDown: false)
                        .font(.headline.weight(.black))
                        .monospacedDigit()
                        .foregroundStyle(warningRed)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text("STALL SESSION LIVE")
                            .font(.caption.weight(.black))
                            .tracking(1)
                        Spacer()
                        Text("Bathroom Ops")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            } compactLeading: {
                Image(systemName: "toilet.fill")
                    .foregroundStyle(warningRed)
                    .accessibilityLabel("Bathroom timer")
            } compactTrailing: {
                Text(timerInterval: context.attributes.startedAt...Date.distantFuture, countsDown: false)
                    .font(.caption2.weight(.black))
                    .monospacedDigit()
                    .foregroundStyle(warningRed)
                    .frame(width: 42)
            } minimal: {
                Image(systemName: "timer")
                    .foregroundStyle(warningRed)
                    .accessibilityLabel("Bathroom timer running")
            }
            .keylineTint(warningRed)
        }
    }
}
