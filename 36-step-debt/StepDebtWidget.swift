import WidgetKit
import SwiftUI
import DumbKit

private struct StepDebtEntry: TimelineEntry {
    let date: Date
    let steps: Int
    let goal: Int
    let remaining: Int
}

private struct StepDebtProvider: TimelineProvider {
    func placeholder(in context: Context) -> StepDebtEntry {
        StepDebtEntry(date: Date(), steps: 4200, goal: 8000, remaining: 3800)
    }

    func getSnapshot(in context: Context, completion: @escaping (StepDebtEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StepDebtEntry>) -> Void) {
        let entry = currentEntry()
        completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(900))))
    }

    private func currentEntry() -> StepDebtEntry {
        let steps = DumbWidgetSync.int(.stepDebt, key: "steps")
        let goal = max(DumbWidgetSync.int(.stepDebt, key: "goal", default: 8000), 1)
        return StepDebtEntry(date: Date(), steps: steps, goal: goal, remaining: max(goal - steps, 0))
    }
}

private struct StepDebtWidgetView: View {
    let entry: StepDebtEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Step debt", systemImage: "figure.walk")
                .font(.caption.weight(.black))
                .foregroundStyle(.secondary)
            Text(entry.remaining == 0 ? "Cleared" : "\(entry.remaining) due")
                .font(.title2.weight(.black))
            ProgressView(value: Double(entry.steps), total: Double(entry.goal))
                .tint(.green)
            Text("\(entry.steps) / \(entry.goal) steps")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(14)
        .containerBackground(for: .widget) { Color(.systemBackground) }
    }
}

struct StepDebtWidget: Widget {
    let kind = "StepDebtWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StepDebtProvider()) { entry in
            StepDebtWidgetView(entry: entry)
        }
        .configurationDisplayName("Step debt")
        .description("Today's fictional step balance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct StepDebtWidgetBundle: WidgetBundle {
    var body: some Widget {
        StepDebtWidget()
    }
}
