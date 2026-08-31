import SwiftUI
import DumbKit

private struct SocialReceipt: Codable, Identifiable {
    let id: UUID
    let eventName: String
    let people: Int
    let minutes: Int
    let before: Int
    let after: Int
    let receipt: String
    let date: Date

    init(
        eventName: String,
        people: Int,
        minutes: Int,
        before: Int,
        after: Int,
        receipt: String,
        date: Date = Date()
    ) {
        id = UUID()
        self.eventName = eventName
        self.people = people
        self.minutes = minutes
        self.before = before
        self.after = after
        self.receipt = receipt
        self.date = date
    }

    var change: Int { after - before }
}

struct SocialBatteryReceiptView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private static let emptyReceipt = "Your receipt is waiting for an honest after-event report."

    @AppStorage("socialBattery.people") private var people = 2.0
    @AppStorage("socialBattery.minutes") private var minutes = 60.0
    @AppStorage("socialBattery.before") private var before = 8.0
    @AppStorage("socialBattery.after") private var after = 3.0
    @AppStorage("socialBattery.eventName") private var eventName = ""
    @AppStorage("socialBattery.receipt") private var receipt = Self.emptyReceipt
    @AppStorage("socialBattery.history") private var storedHistory = "[]"

    @State private var history: [SocialReceipt] = []
    @State private var hasLoaded = false
    @State private var showAllHistory = false
    @State private var showEraseConfirmation = false

    private let accent = CorpPalette.violet

    var body: some View {
        AppCanvas(accent: accent, experience: .receipt) {
            AppHeader(
                eyebrow: "SOCIAL BATTERY",
                title: "Thank you for socializing.",
                subtitle: "A receipt for the social energy you actually felt—not a personality prediction.",
                accent: accent
            )

            boundaryCard
            summaryCard
            receiptEditor

            socialReceiptPaper
            .accessibilityIdentifier("socialBatteryResult")

            Button(action: resetCurrentReceipt) {
            Label("Void current receipt", systemImage: "arrow.counterclockwise")
            .font(.subheadline.weight(.black))
            .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(!hasCurrentReceipt)
            .accessibilityIdentifier("resetReceiptButton")
            .accessibilityHint("Resets the current report without deleting filed history.")

            historyCard

            Button {
            showEraseConfirmation = true
            } label: {
            Label("Erase every receipt", systemImage: "trash.fill")
            .font(.subheadline.weight(.black))
            .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(history.isEmpty && !hasCurrentReceipt)
            .accessibilityIdentifier("eraseSocialBatteryDataButton")

        } bottomBar: {
            DumbAction(
            title: "Print & file emotional receipt",
            accent: accent,
            systemImage: "receipt.fill",
            action: makeReceipt
            )
            .accessibilityIdentifier("printReceiptButton")

        }
        .onAppear(perform: restoreHistory)
        .onChange(of: eventName) { _, _ in invalidateReceipt() }
        .onChange(of: people) { _, _ in invalidateReceipt() }
        .onChange(of: minutes) { _, _ in invalidateReceipt() }
        .onChange(of: before) { _, _ in invalidateReceipt() }
        .onChange(of: after) { _, _ in invalidateReceipt() }
        .confirmationDialog(
            "Erase the current receipt and every filed event?",
            isPresented: $showEraseConfirmation,
            titleVisibility: .visible
        ) {
            Button("Confirm erase every receipt", role: .destructive, action: eraseAllData)
            Button("Keep the receipts", role: .cancel) {}
        } message: {
            Text("This erases every social battery receipt. It cannot be undone.")
        }
    }

    private var boundaryCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 7) {
                DumbStatusPill(
                    "NO FAKE PSYCHOLOGY",
                    systemImage: "equal.circle.fill",
                    accent: accent
                )
                Text("Choose how you felt before and after. The receipt describes this event—it does not predict the next one.")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CorpPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var summaryCard: some View {
        DumbCard(accent: accent, isSelected: !history.isEmpty) {
            HStack(spacing: 10) {
                summaryMetric(value: "\(history.count)", label: "filed")
                Divider()
                summaryMetric(value: formatDuration(totalMinutes), label: "logged")
                Divider()
                summaryMetric(value: formattedAverageChange, label: "avg change")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("socialBatterySummary")
        .accessibilityLabel("Social battery history summary")
        .accessibilityValue("\(history.count) filed, \(totalMinutes) minutes logged, average change \(formattedAverageChange)")
    }

    private func summaryMetric(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.title3.weight(.black))
                .foregroundStyle(accent)
                .minimumScaleFactor(0.75)
            Text(label.uppercased())
                .font(.caption2.weight(.black))
                .tracking(0.6)
                .foregroundStyle(CorpPalette.mutedInk)
        }
        .frame(maxWidth: .infinity)
    }

    private var receiptEditor: some View {
        DumbCard(accent: accent, isSelected: after < before) {
            VStack(alignment: .leading, spacing: 14) {
                Text("FILE THE ACTUAL EVENT")
                    .font(.caption2.weight(.black))
                    .tracking(1.2)
                    .foregroundStyle(CorpPalette.mutedInk)
                DumbField("Event name (optional)", maxLength: 80, text: $eventName)
                DumbSlider(title: "People involved", value: $people, range: 1...20, step: 1, accent: accent)
                DumbSlider(title: "Minutes socialized", value: $minutes, range: 5...360, step: 5, accent: accent)
                DumbSlider(title: "Energy before", value: $before, range: 0...10, step: 1, accent: accent)
                DumbSlider(title: "Energy after", value: $after, range: 0...10, step: 1, accent: accent)
            }
        }
    }

    private var historyCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 11) {
                HStack {
                    Text("RECEIPT ARCHIVE")
                        .font(.caption2.weight(.black))
                        .tracking(1.2)
                        .foregroundStyle(CorpPalette.mutedInk)
                    Spacer()
                    Text("\(history.count) receipts")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .accessibilityIdentifier("socialBatteryHistoryCount")
                        .accessibilityValue("\(history.count)")
                }

                if history.isEmpty {
                    Label("No social event has submitted expenses.", systemImage: "receipt")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(CorpPalette.ink)
                        .accessibilityIdentifier("emptySocialBatteryHistory")
                } else {
                    ForEach(visibleHistory) { record in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                DumbStatusPill(
                                    changeLabel(record.change).uppercased(),
                                    systemImage: record.change < 0 ? "battery.25percent" : "battery.100percent",
                                    accent: accent
                                )
                                Spacer()
                                Text(record.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(CorpPalette.mutedInk)
                            }
                            Text(record.eventName.isEmpty ? "Unnamed social event" : record.eventName)
                                .font(.headline.weight(.black))
                                .foregroundStyle(CorpPalette.ink)
                            Text("\(record.people) people · \(formatDuration(record.minutes)) · \(record.before)/10 → \(record.after)/10")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(CorpPalette.ink)
                            Button(role: .destructive) {
                                delete(record)
                            } label: {
                                Label("Delete social receipt", systemImage: "trash")
                                    .font(.caption.weight(.black))
                            }
                            .accessibilityIdentifier("deleteSocialReceiptButton")
                        }
                        .padding(.vertical, 3)
                    }

                    if history.count > 5 {
                        Button(showAllHistory ? "Show newest five" : "Browse all \(history.count)") {
                            withAnimation(reduceMotion ? nil : .snappy) { showAllHistory.toggle() }
                        }
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(accent)
                        .accessibilityIdentifier("toggleSocialHistoryButton")
                    }
                }
            }
        }
    }

    private var visibleHistory: [SocialReceipt] {
        showAllHistory ? history : Array(history.prefix(5))
    }

    private var totalMinutes: Int {
        history.reduce(0) { $0 + $1.minutes }
    }

    private var formattedAverageChange: String {
        guard !history.isEmpty else { return "0" }
        let average = Double(history.reduce(0) { $0 + $1.change }) / Double(history.count)
        if average == average.rounded() { return signed(Int(average)) }
        return String(format: "%+.1f", average)
    }

    private var batterySymbol: String {
        switch Int(after) {
        case 0...2: return "battery.0percent"
        case 3...5: return "battery.25percent"
        case 6...8: return "battery.75percent"
        default: return "battery.100percent"
        }
    }

    private var socialReceiptPaper: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SOCIAL BATTERY RECEIPT")
                        .font(.caption.weight(.black).monospaced())
                        .tracking(1.2)
                    Text("FILED FOR THIS EVENT ONLY")
                        .font(.caption2.weight(.bold).monospaced())
                        .foregroundStyle(CorpPalette.mutedInk)
                }
                Spacer()
                Image(systemName: batterySymbol)
                    .font(.title2.weight(.black))
                    .foregroundStyle(accent)
                    .accessibilityHidden(true)
            }
            Rectangle()
                .fill(accent)
                .frame(height: 2)
            Text(receipt)
                .font(.system(.subheadline, design: .monospaced).weight(.bold))
                .foregroundStyle(CorpPalette.ink)
                .fixedSize(horizontal: false, vertical: true)
                .contentTransition(.opacity)
        }
        .padding(DumbSpacing.md)
        .background(CorpPalette.receiptCream, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .stroke(CorpPalette.ink.opacity(0.08), lineWidth: 1)
        )
        .rotationEffect(.degrees(receipt == Self.emptyReceipt ? 0 : -0.6))
        .shadow(color: .black.opacity(0.06), radius: 2, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Social battery receipt")
        .accessibilityValue(receipt)
    }

    private var hasCurrentReceipt: Bool {
        !eventName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || people != 2
            || minutes != 60
            || before != 8
            || after != 3
            || receipt != Self.emptyReceipt
    }

    private func makeReceipt() {
        let beforeScore = Int(before)
        let afterScore = Int(after)
        let change = afterScore - beforeScore
        let finding: String
        if change < 0 {
            finding = "Observed drain: \(-change) points over \(Int(minutes)) minutes."
        } else if change > 0 {
            finding = "Recharge credit: +\(change) points over \(Int(minutes)) minutes."
        } else {
            finding = "Battery broke even over \(Int(minutes)) minutes."
        }
        let status: String
        switch afterScore {
        case 0...2: status = "Reported status: critically low. Recovery plans remain your call."
        case 3...5: status = "Reported status: low. Your next move remains your call."
        case 6...8: status = "Reported status: operational."
        default: status = "Reported status: suspiciously charged."
        }

        let name = eventName.trimmingCharacters(in: .whitespacesAndNewlines)
        receipt = "SOCIAL BATTERY RECEIPT — \(name.isEmpty ? "Unnamed event" : name). \(Int(people)) people · \(Int(minutes)) min. Reported change: \(beforeScore)/10 → \(afterScore)/10 (\(signed(change))). \(finding) \(status) Filed for this event only."
        history.insert(
            SocialReceipt(
                eventName: name,
                people: Int(people),
                minutes: Int(minutes),
                before: beforeScore,
                after: afterScore,
                receipt: receipt
            ),
            at: 0
        )
        history = Array(history.prefix(30))
        persistHistory()
    }

    private func signed(_ value: Int) -> String {
        value > 0 ? "+\(value)" : "\(value)"
    }

    private func changeLabel(_ value: Int) -> String {
        value < 0 ? "Drain \(-value)" : value > 0 ? "Credit +\(value)" : "Break even"
    }

    private func formatDuration(_ minutes: Int) -> String {
        if minutes < 60 { return "\(minutes)m" }
        let hours = minutes / 60
        let remainder = minutes % 60
        return remainder == 0 ? "\(hours)h" : "\(hours)h \(remainder)m"
    }

    private func invalidateReceipt() {
        guard receipt != Self.emptyReceipt else { return }
        receipt = "Event changed. Print a fresh emotional receipt."
    }

    private func resetCurrentReceipt() {
        people = 2
        minutes = 60
        before = 8
        after = 3
        eventName = ""
        receipt = Self.emptyReceipt
    }

    private func delete(_ record: SocialReceipt) {
        history.removeAll { $0.id == record.id }
        persistHistory()
    }

    private func eraseAllData() {
        history = []
        showAllHistory = false
        resetCurrentReceipt()
        persistHistory()
    }

    private func restoreHistory() {
        guard !hasLoaded else { return }
        hasLoaded = true
        guard
            let data = storedHistory.data(using: .utf8),
            let saved = try? JSONDecoder().decode([SocialReceipt].self, from: data)
        else { return }
        history = saved.sorted { $0.date > $1.date }
    }

    private func persistHistory() {
        guard
            let data = try? JSONEncoder().encode(history),
            let value = String(data: data, encoding: .utf8)
        else { return }
        storedHistory = value
    }
}

#if canImport(PreviewsMacros)
#Preview { SocialBatteryReceiptView() }
#endif
