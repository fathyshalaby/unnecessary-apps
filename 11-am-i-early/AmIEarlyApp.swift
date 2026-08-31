import SwiftUI
import DumbKit

private struct ArrivalRecord: Codable, Identifiable {
    let id: UUID
    let occasion: String
    let offsetMinutes: Int
    let verdict: String
    let date: Date

    init(occasion: String, offsetMinutes: Int, verdict: String, date: Date = Date()) {
        id = UUID()
        self.occasion = occasion
        self.offsetMinutes = offsetMinutes
        self.verdict = verdict
        self.date = date
    }
}

@main
struct AmIEarlyApp: App {
    var body: some Scene { WindowGroup { AmIEarlyView().dumbNativeEntry(scheme: "app11amiearly") { _, _ in } } }
}

struct AmIEarlyView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private static let emptyResult = "Awaiting your arrival report."

    @AppStorage("amIEarly.minutes") private var minutes = 12.0
    @AppStorage("amIEarly.occasion") private var occasion = ""
    @AppStorage("amIEarly.result") private var result = Self.emptyResult
    @AppStorage("amIEarly.history") private var storedHistory = "[]"

    @State private var history: [ArrivalRecord] = []
    @State private var hasLoaded = false
    @State private var showAllHistory = false
    @State private var showEraseConfirmation = false

    private let accent = CorpPalette.parkGreen

    var body: some View {
        AppCanvas(accent: accent, experience: .meter) {
            AppHeader(
                eyebrow: "PUNCTUALITY SERVICES",
                title: "Am I early?",
                subtitle: "A social question disguised as a signed number.",
                accent: accent
            )

            summaryCard
            arrivalEditor
            historyCard

            Button(action: resetCurrentReport) {
                Label("Reset current report", systemImage: "arrow.counterclockwise")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(!hasCurrentReport)
            .accessibilityIdentifier("resetPunctualityButton")
            .accessibilityHint("Resets the current occasion and offset without deleting filed history.")

            Button {
                showEraseConfirmation = true
            } label: {
                Label("Erase every arrival", systemImage: "trash.fill")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(history.isEmpty && !hasCurrentReport)
            .accessibilityIdentifier("erasePunctualityDataButton")
        } bottomBar: {
            DumbAction(
                title: "Issue & file punctuality verdict",
                accent: accent,
                systemImage: "clock.badge.checkmark",
                action: issueVerdict
            )
            .accessibilityIdentifier("punctualityButton")

            DumbResult(
                text: result,
                accent: accent,
                systemImage: "clock.fill",
                reactionStyle: isActiveVerdict ? .stamp : .bounce
            )
            .accessibilityIdentifier("punctualityResult")
        }
        .onAppear(perform: restoreHistory)
        .onChange(of: minutes) { _, _ in invalidateVerdict() }
        .onChange(of: occasion) { _, _ in invalidateVerdict() }
        .confirmationDialog(
            "Erase the current report and every filed arrival?",
            isPresented: $showEraseConfirmation,
            titleVisibility: .visible
        ) {
            Button("Confirm erase every arrival", role: .destructive, action: eraseAllData)
            Button("Keep the records", role: .cancel) {}
        } message: {
            Text("This erases every arrival record. It cannot be undone.")
        }
    }

    private var summaryCard: some View {
        DumbCard(accent: accent, isSelected: !history.isEmpty) {
            VStack(spacing: 14) {
                offsetGauge

                HStack(spacing: 10) {
                    summaryMetric(value: history.count, label: "filed")
                    Divider()
                    summaryMetric(value: notLateCount, label: "not late")
                    Divider()
                    summaryMetric(value: lateCount, label: "late")
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("punctualitySummary")
        .accessibilityLabel("Punctuality history summary")
        .accessibilityValue("\(Int(minutes)) minute offset, \(history.count) filed, \(notLateCount) not late, \(lateCount) late")
    }

    private var offsetGauge: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(accent.opacity(0.16), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: offsetGaugeProgress)
                    .stroke(accent, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 2) {
                    Text(offsetGaugeLabel)
                        .font(.caption.weight(.black))
                        .foregroundStyle(accent)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }
                .padding(8)
            }
            .frame(width: 72, height: 72)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text("CURRENT OFFSET")
                    .font(.caption2.weight(.black))
                    .tracking(1.1)
                    .foregroundStyle(accent)
                Text(offsetDescription)
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(CorpPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Late ← on time → early")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(CorpPalette.mutedInk)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var offsetGaugeProgress: CGFloat {
        CGFloat((minutes + 30) / 90)
    }

    private var offsetGaugeLabel: String {
        let offset = Int(minutes)
        if offset > 0 { return "+\(offset)" }
        if offset < 0 { return "\(offset)" }
        return "0"
    }

    private var offsetDescription: String {
        let offset = Int(minutes)
        if offset > 0 { return "\(offset) minutes early" }
        if offset < 0 { return "\(-offset) minutes late" }
        return "Exactly on time"
    }

    private var isActiveVerdict: Bool {
        result != Self.emptyResult && !result.hasPrefix("Arrival changed.")
    }

    private func summaryMetric(value: Int, label: String) -> some View {
        VStack(spacing: 3) {
            Text("\(value)")
                .font(.title2.weight(.black))
                .foregroundStyle(accent)
                .contentTransition(.numericText())
            Text(label.uppercased())
                .font(.caption2.weight(.black))
                .tracking(0.7)
                .foregroundStyle(CorpPalette.mutedInk)
        }
        .frame(maxWidth: .infinity)
    }

    private var arrivalEditor: some View {
        DumbCard(accent: accent, isSelected: minutes < 0) {
            VStack(alignment: .leading, spacing: 13) {
                Text("FILE AN ARRIVAL")
                    .font(.caption2.weight(.black))
                    .tracking(1.2)
                    .foregroundStyle(CorpPalette.mutedInk)

                DumbField(
                    "Occasion (optional)",
                    maxLength: 80,
                    text: $occasion
                )

                DumbSlider(
                    title: "Minutes before the appointment",
                    value: $minutes,
                    range: -30...60,
                    step: 1,
                    accent: accent
                )

                Text("Positive means early. Zero is exactly on time. Negative means late.")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CorpPalette.mutedInk)
            }
        }
    }

    private var historyCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 11) {
                HStack {
                    Text("ARRIVAL FILES")
                        .font(.caption2.weight(.black))
                        .tracking(1.2)
                        .foregroundStyle(CorpPalette.mutedInk)
                    Spacer()
                    Text("\(history.count) records")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .accessibilityIdentifier("punctualityHistoryCount")
                        .accessibilityValue("\(history.count)")
                }

                if history.isEmpty {
                    Label("No arrivals have testified yet.", systemImage: "clock.badge.questionmark")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(CorpPalette.ink)
                        .accessibilityIdentifier("emptyPunctualityHistory")
                } else {
                    ForEach(visibleHistory) { record in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                DumbStatusPill(
                                    offsetLabel(record.offsetMinutes).uppercased(),
                                    systemImage: record.offsetMinutes >= -5 ? "checkmark.circle.fill" : "exclamationmark.circle.fill",
                                    accent: accent
                                )
                                Spacer()
                                Text(record.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(CorpPalette.mutedInk)
                            }
                            Text(record.occasion.isEmpty ? "Unnamed appointment" : record.occasion)
                                .font(.headline.weight(.black))
                                .foregroundStyle(CorpPalette.ink)
                            Text(record.verdict)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(CorpPalette.ink)
                                .fixedSize(horizontal: false, vertical: true)
                            Button(role: .destructive) {
                                delete(record)
                            } label: {
                                Label("Delete arrival record", systemImage: "trash")
                                    .font(.caption.weight(.black))
                            }
                            .accessibilityIdentifier("deletePunctualityRecordButton")
                        }
                        .padding(.vertical, 3)
                    }

                    if history.count > 5 {
                        Button(showAllHistory ? "Show newest five" : "Browse all \(history.count)") {
                            withAnimation(reduceMotion ? nil : .snappy) {
                                showAllHistory.toggle()
                            }
                        }
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(accent)
                        .accessibilityIdentifier("togglePunctualityHistoryButton")
                    }
                }
            }
        }
    }

    private var visibleHistory: [ArrivalRecord] {
        showAllHistory ? history : Array(history.prefix(5))
    }

    private var notLateCount: Int {
        history.filter { $0.offsetMinutes >= -5 }.count
    }

    private var lateCount: Int {
        history.count - notLateCount
    }

    private var hasCurrentReport: Bool {
        !occasion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || minutes != 0
            || result != Self.emptyResult
    }

    private func issueVerdict() {
        let offset = Int(minutes)
        let verdict = verdictText(for: offset)
        result = verdict
        history.insert(
            ArrivalRecord(
                occasion: occasion.trimmingCharacters(in: .whitespacesAndNewlines),
                offsetMinutes: offset,
                verdict: verdict
            ),
            at: 0
        )
        history = Array(history.prefix(30))
        persistHistory()
    }

    private func verdictText(for offset: Int) -> String {
        switch offset {
        case 21...:
            return "You are early enough to become staff."
        case 6...20:
            return "Comfortably early. You may pretend this was effortless."
        case -5...5:
            return "On time. The punctuality office finds no drama."
        case -15 ... -6:
            return "Late, but still inside the plausible-excuse window."
        default:
            return "You are causing a scene. Walk faster and stop narrating it."
        }
    }

    private func offsetLabel(_ offset: Int) -> String {
        if offset > 0 { return "\(offset) min early" }
        if offset < 0 { return "\(-offset) min late" }
        return "On time"
    }

    private func invalidateVerdict() {
        guard result != Self.emptyResult else { return }
        result = "Arrival changed. Issue a fresh punctuality verdict."
    }

    private func resetCurrentReport() {
        occasion = ""
        minutes = 0
        result = Self.emptyResult
    }

    private func delete(_ record: ArrivalRecord) {
        history.removeAll { $0.id == record.id }
        persistHistory()
    }

    private func eraseAllData() {
        history = []
        showAllHistory = false
        occasion = ""
        minutes = 0
        result = Self.emptyResult
        persistHistory()
    }

    private func restoreHistory() {
        guard !hasLoaded else { return }
        hasLoaded = true
        guard
            let data = storedHistory.data(using: .utf8),
            let saved = try? JSONDecoder().decode([ArrivalRecord].self, from: data)
        else {
            return
        }
        history = saved.sorted { $0.date > $1.date }
    }

    private func persistHistory() {
        guard
            let data = try? JSONEncoder().encode(history),
            let value = String(data: data, encoding: .utf8)
        else {
            return
        }
        storedHistory = value
    }
}
