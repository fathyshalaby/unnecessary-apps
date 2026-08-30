import WidgetKit
import SwiftUI
import DumbKit

private struct CooldownEntry: TimelineEntry {
    let date: Date
    let remaining: Int
    let isActive: Bool
}

private struct CooldownProvider: TimelineProvider {
    func placeholder(in context: Context) -> CooldownEntry {
        CooldownEntry(date: Date(), remaining: 10, isActive: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (CooldownEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CooldownEntry>) -> Void) {
        let entry = currentEntry()
        let policy: TimelineReloadPolicy = entry.isActive
            ? .after(Date().addingTimeInterval(1))
            : .after(Date().addingTimeInterval(900))
        completion(Timeline(entries: [entry], policy: policy))
    }

    private func currentEntry() -> CooldownEntry {
        let remaining = DumbWidgetSync.int(.doNotTextThem, key: "remaining")
        let isActive = DumbWidgetSync.string(.doNotTextThem, key: "active") == "1"
        return CooldownEntry(date: Date(), remaining: remaining, isActive: isActive)
    }
}

private struct CooldownWidgetView: View {
    let entry: CooldownEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Do not text", systemImage: "hand.raised.fill")
                .font(.caption.weight(.black))
                .foregroundStyle(.secondary)
            if entry.isActive, entry.remaining > 0 {
                Text("\(entry.remaining)s")
                    .font(.system(.largeTitle, design: .rounded).weight(.black))
                    .foregroundStyle(.red)
                Text("Cooling off")
                    .font(.caption.weight(.semibold))
            } else {
                Text("Ready")
                    .font(.title.weight(.black))
                Text("Open to start intervention")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(14)
        .containerBackground(for: .widget) { Color(.systemBackground) }
    }
}

struct DoNotTextThemWidget: Widget {
    let kind = "DoNotTextThemWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CooldownProvider()) { entry in
            CooldownWidgetView(entry: entry)
        }
        .configurationDisplayName("Do Not Text Them")
        .description("Cool-off countdown at a glance.")
        .supportedFamilies([.systemSmall])
    }
}

@main
struct DoNotTextThemWidgetBundle: WidgetBundle {
    var body: some Widget {
        DoNotTextThemWidget()
    }
}
