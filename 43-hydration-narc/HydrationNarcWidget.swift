import WidgetKit
import SwiftUI
import DumbKit

private struct HydrationEntry: TimelineEntry {
    let date: Date
    let servings: Int
    let goal: Int
}

private struct HydrationProvider: TimelineProvider {
    func placeholder(in context: Context) -> HydrationEntry {
        HydrationEntry(date: Date(), servings: 3, goal: 8)
    }

    func getSnapshot(in context: Context, completion: @escaping (HydrationEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HydrationEntry>) -> Void) {
        completion(Timeline(entries: [currentEntry()], policy: .after(Date().addingTimeInterval(900))))
    }

    private func currentEntry() -> HydrationEntry {
        HydrationEntry(
            date: Date(),
            servings: DumbWidgetSync.int(.hydration, key: "servings"),
            goal: max(DumbWidgetSync.int(.hydration, key: "goal", default: 8), 1)
        )
    }
}

private struct HydrationWidgetView: View {
    let entry: HydrationEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Hydration", systemImage: "drop.fill")
                .font(.caption.weight(.black))
                .foregroundStyle(.secondary)
            Text("\(entry.servings)/\(entry.goal)")
                .font(.system(.title, design: .rounded).weight(.black))
            ProgressView(value: Double(entry.servings), total: Double(entry.goal))
                .tint(.blue)
            Text(entry.servings >= entry.goal ? "Case closed." : "Log another serving.")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(14)
        .containerBackground(for: .widget) { Color(.systemBackground) }
    }
}

struct HydrationNarcWidget: Widget {
    let kind = "HydrationNarcWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HydrationProvider()) { entry in
            HydrationWidgetView(entry: entry)
        }
        .configurationDisplayName("Hydration narc")
        .description("Today's serving ledger.")
        .supportedFamilies([.systemSmall])
    }
}

@main
struct HydrationNarcWidgetBundle: WidgetBundle {
    var body: some Widget {
        HydrationNarcWidget()
    }
}
