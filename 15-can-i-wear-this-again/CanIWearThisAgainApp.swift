import SwiftUI
import DumbKit

private struct ClosetRuling: Codable, Identifiable {
    let id: UUID
    let itemName: String
    let daysSinceWear: Int
    let wearsSinceWash: Int
    let personalLimit: Int
    let approved: Bool
    let verdict: String
    let date: Date

    init(
        itemName: String,
        daysSinceWear: Int,
        wearsSinceWash: Int,
        personalLimit: Int,
        approved: Bool,
        verdict: String,
        date: Date = Date()
    ) {
        id = UUID()
        self.itemName = itemName
        self.daysSinceWear = daysSinceWear
        self.wearsSinceWash = wearsSinceWash
        self.personalLimit = personalLimit
        self.approved = approved
        self.verdict = verdict
        self.date = date
    }

    var projectedWears: Int { wearsSinceWash + 1 }
}

@main
struct CanIWearThisAgainApp: App {
    var body: some Scene { WindowGroup { OutfitView().dumbNativeEntry(scheme: "app15caniwearthisagain") { _, _ in } } }
}

struct OutfitView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private static let emptyResult = "The closet is waiting for honest evidence."

    @AppStorage("outfit.days") private var daysSinceWear = 2.0
    @AppStorage("outfit.wearsSinceWash") private var wearsSinceWash = 1.0
    @AppStorage("outfit.personalLimit") private var personalLimit = 3.0
    @AppStorage("outfit.itemName") private var itemName = ""
    @AppStorage("outfit.hasOdor") private var hasOdor = false
    @AppStorage("outfit.hasStain") private var hasStain = false
    @AppStorage("outfit.wasSweaty") private var wasSweaty = false
    @AppStorage("outfit.result") private var result = Self.emptyResult
    @AppStorage("outfit.history") private var storedHistory = "[]"

    @State private var history: [ClosetRuling] = []
    @State private var hasLoaded = false
    @State private var showAllHistory = false
    @State private var showEraseConfirmation = false

    private let accent = CorpPalette.coral

    var body: some View {
        AppCanvas(accent: accent) {
            AppHeader(
                eyebrow: "WARDROBE COMPLIANCE",
                title: "Wear it again?",
                subtitle: "Your rules, your evidence, your suspiciously formal closet ruling.",
                accent: accent
            )

            boundaryCard
            summaryCard
            rulingEditor

            if result != Self.emptyResult, let banner = rulingBanner {
            DumbCard(accent: accent, isSelected: true) {
            HStack(spacing: 12) {
            Image(systemName: banner.approved ? "checkmark.seal.fill" : "washer.fill")
            .font(.title2.weight(.black))
            .foregroundStyle(banner.approved ? accent : CorpPalette.warningRed)
            Text(banner.title)
            .font(.system(.title3, design: .rounded).weight(.black))
            .foregroundStyle(CorpPalette.ink)
            }
            }
            .accessibilityIdentifier("closetRulingBanner")
            }

            Button(action: resetCurrentRuling) {
            Label("Reset current evidence", systemImage: "arrow.counterclockwise")
            .font(.subheadline.weight(.black))
            .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(!hasCurrentRuling)
            .accessibilityIdentifier("resetOutfitButton")
            .accessibilityHint("Resets the current evidence without deleting filed rulings.")

            historyCard

            Button {
            showEraseConfirmation = true
            } label: {
            Label("Erase every wardrobe ruling", systemImage: "trash.fill")
            .font(.subheadline.weight(.black))
            .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(history.isEmpty && !hasCurrentRuling)
            .accessibilityIdentifier("eraseWardrobeDataButton")

        } bottomBar: {
            DumbAction(
            title: "Issue & file closet ruling",
            accent: accent,
            systemImage: "tshirt.fill",
            action: issueRuling
            )
            .accessibilityIdentifier("askClosetButton")

            DumbResult(
            text: result,
            accent: accent,
            systemImage: "checkmark.seal.fill",
            reactionStyle: .stamp
            )
            .accessibilityIdentifier("closetRulingResult")

        }
        .onAppear(perform: restoreHistory)
        .onChange(of: daysSinceWear) { _, _ in invalidateRuling() }
        .onChange(of: wearsSinceWash) { _, _ in invalidateRuling() }
        .onChange(of: personalLimit) { _, _ in invalidateRuling() }
        .onChange(of: itemName) { _, _ in invalidateRuling() }
        .onChange(of: hasOdor) { _, _ in invalidateRuling() }
        .onChange(of: hasStain) { _, _ in invalidateRuling() }
        .onChange(of: wasSweaty) { _, _ in invalidateRuling() }
        .confirmationDialog(
            "Erase the current evidence and every filed ruling?",
            isPresented: $showEraseConfirmation,
            titleVisibility: .visible
        ) {
            Button("Confirm erase every wardrobe ruling", role: .destructive, action: eraseAllData)
            Button("Keep the closet files", role: .cancel) {}
        } message: {
            Text("This erases every wardrobe ruling. It cannot be undone.")
        }
    }

    private var boundaryCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 7) {
                DumbStatusPill(
                    "HONEST CLOSET POLICY",
                    systemImage: "checklist",
                    accent: accent
                )
                Text("You set the wear limit and report the evidence. The garment will not be sniff-tested by committee.")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CorpPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var summaryCard: some View {
        DumbCard(accent: accent, isSelected: !history.isEmpty) {
            HStack(spacing: 10) {
                summaryMetric(value: history.count, label: "filed")
                Divider()
                summaryMetric(value: approvedCount, label: "approved")
                Divider()
                summaryMetric(value: laundryCount, label: "laundry")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("closetSummary")
        .accessibilityLabel("Closet ruling summary")
        .accessibilityValue("\(history.count) filed, \(approvedCount) approved, \(laundryCount) laundry")
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

    private var rulingEditor: some View {
        DumbCard(accent: accent, isSelected: hasOdor || hasStain || wasSweaty) {
            VStack(alignment: .leading, spacing: 14) {
                Text("PRESENT THE EVIDENCE")
                    .font(.caption2.weight(.black))
                    .tracking(1.2)
                    .foregroundStyle(CorpPalette.mutedInk)

                DumbField(
                    "Item or outfit name (optional)",
                    maxLength: 80,
                    text: $itemName
                )

                Text("CONDITION EVIDENCE")
                    .font(.caption2.weight(.black))
                    .tracking(1.2)
                    .foregroundStyle(CorpPalette.mutedInk)

                conditionToggle(
                    "Odor noticed",
                    subtitle: "Your nose has entered evidence.",
                    isOn: $hasOdor,
                    identifier: "odorToggle"
                )
                conditionToggle(
                    "Visible stain",
                    subtitle: "The item is carrying a receipt.",
                    isOn: $hasStain,
                    identifier: "stainToggle"
                )
                conditionToggle(
                    "Sweaty or intense last wear",
                    subtitle: "Gym, heat, dancing, or similar chaos.",
                    isOn: $wasSweaty,
                    identifier: "sweatyWearToggle"
                )

                Divider()

                DumbSlider(
                    title: "Completed wears since washing",
                    value: $wearsSinceWash,
                    range: 0...10,
                    step: 1,
                    accent: accent
                )
                DumbSlider(
                    title: "Your maximum wears before washing",
                    value: $personalLimit,
                    range: 1...10,
                    step: 1,
                    accent: accent
                )
                DumbSlider(
                    title: "Days since last wear (social context only)",
                    value: $daysSinceWear,
                    range: 0...14,
                    step: 1,
                    accent: accent
                )
            }
        }
    }

    private var rulingBanner: (approved: Bool, title: String)? {
        guard result != Self.emptyResult else { return nil }
        if result.localizedCaseInsensitiveContains("laundry") || result.localizedCaseInsensitiveContains("wash") {
            return (false, "LAUNDRY")
        }
        if result.localizedCaseInsensitiveContains("approved") || result.localizedCaseInsensitiveContains("wear again") {
            return (true, "APPROVED")
        }
        return nil
    }

    private func conditionToggle(
        _ title: String,
        subtitle: String,
        isOn: Binding<Bool>,
        identifier: String
    ) -> some View {
        Toggle(isOn: isOn) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(CorpPalette.ink)
                Text(subtitle)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
            }
        }
        .tint(accent)
        .accessibilityIdentifier(identifier)
    }

    private var historyCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 11) {
                HStack {
                    Text("CLOSET CASE FILES")
                        .font(.caption2.weight(.black))
                        .tracking(1.2)
                        .foregroundStyle(CorpPalette.mutedInk)
                    Spacer()
                    Text("\(history.count) rulings")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .accessibilityIdentifier("closetHistoryCount")
                        .accessibilityValue("\(history.count)")
                }

                if history.isEmpty {
                    Label("No garment has faced judgment yet.", systemImage: "tshirt")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(CorpPalette.ink)
                        .accessibilityIdentifier("emptyClosetHistory")
                } else {
                    ForEach(visibleHistory) { ruling in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                DumbStatusPill(
                                    ruling.approved ? "APPROVED" : "LAUNDRY",
                                    systemImage: ruling.approved ? "checkmark.seal.fill" : "washer.fill",
                                    accent: accent
                                )
                                Spacer()
                                Text(ruling.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(CorpPalette.mutedInk)
                            }
                            Text(ruling.itemName.isEmpty ? "Unnamed garment" : ruling.itemName)
                                .font(.headline.weight(.black))
                                .foregroundStyle(CorpPalette.ink)
                            Text("Next wear: \(ruling.projectedWears) of \(ruling.personalLimit) · last seen \(repeatLabel(ruling.daysSinceWear))")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(CorpPalette.ink)
                            Text(ruling.verdict)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(CorpPalette.mutedInk)
                                .fixedSize(horizontal: false, vertical: true)
                            Button(role: .destructive) {
                                delete(ruling)
                            } label: {
                                Label("Delete closet ruling", systemImage: "trash")
                                    .font(.caption.weight(.black))
                            }
                            .accessibilityIdentifier("deleteClosetRulingButton")
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
                        .accessibilityIdentifier("toggleClosetHistoryButton")
                    }
                }
            }
        }
    }

    private var visibleHistory: [ClosetRuling] {
        showAllHistory ? history : Array(history.prefix(5))
    }

    private var approvedCount: Int {
        history.filter { $0.approved }.count
    }

    private var laundryCount: Int {
        history.count - approvedCount
    }

    private var hasCurrentRuling: Bool {
        !itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || daysSinceWear != 2
            || wearsSinceWash != 1
            || personalLimit != 3
            || hasOdor
            || hasStain
            || wasSweaty
            || result != Self.emptyResult
    }

    private func issueRuling() {
        let projectedWears = Int(wearsSinceWash) + 1
        let limit = Int(personalLimit)
        let conditionFlags = markedConditionFlags
        let approved: Bool
        let careRuling: String

        if !conditionFlags.isEmpty {
            approved = false
            careRuling = "Laundry has jurisdiction. You marked \(conditionFlags.joined(separator: ", ")). Resting time does not remove those signals."
        } else if projectedWears > limit {
            approved = false
            careRuling = "Your own limit says laundry. Another wear would be \(projectedWears) wears since washing, above your \(limit)-wear limit."
        } else {
            approved = true
            careRuling = "Approved by your own rules. Another wear makes \(projectedWears) of \(limit) allowed wears, and you marked no condition flags."
        }

        let repeatRuling = repeatVerdict(Int(daysSinceWear))
        result = "\(careRuling) \(repeatRuling)"
        history.insert(
            ClosetRuling(
                itemName: itemName.trimmingCharacters(in: .whitespacesAndNewlines),
                daysSinceWear: Int(daysSinceWear),
                wearsSinceWash: Int(wearsSinceWash),
                personalLimit: limit,
                approved: approved,
                verdict: "\(careRuling) \(repeatRuling)"
            ),
            at: 0
        )
        history = Array(history.prefix(30))
        persistHistory()
    }

    private var markedConditionFlags: [String] {
        var flags: [String] = []
        if hasOdor { flags.append("odor") }
        if hasStain { flags.append("a visible stain") }
        if wasSweaty { flags.append("a sweaty or intense last wear") }
        return flags
    }

    private func repeatVerdict(_ days: Int) -> String {
        switch days {
        case 0:
            return "Repeat visibility: same-day sequel. Bold."
        case 1:
            return "Repeat visibility: yesterday’s outfit returns for season two."
        case 2...3:
            return "Repeat visibility: close enough for attentive witnesses."
        default:
            return "Repeat visibility: socially ancient; no calendar drama detected."
        }
    }

    private func repeatLabel(_ days: Int) -> String {
        if days == 0 { return "today" }
        if days == 1 { return "yesterday" }
        return "\(days) days ago"
    }

    private func invalidateRuling() {
        guard result != Self.emptyResult else { return }
        result = "Evidence changed. Issue a fresh closet ruling."
    }

    private func resetCurrentRuling() {
        daysSinceWear = 2
        wearsSinceWash = 1
        personalLimit = 3
        itemName = ""
        hasOdor = false
        hasStain = false
        wasSweaty = false
        result = Self.emptyResult
    }

    private func delete(_ ruling: ClosetRuling) {
        history.removeAll { $0.id == ruling.id }
        persistHistory()
    }

    private func eraseAllData() {
        history = []
        showAllHistory = false
        resetCurrentRuling()
        persistHistory()
    }

    private func restoreHistory() {
        guard !hasLoaded else { return }
        hasLoaded = true
        guard
            let data = storedHistory.data(using: .utf8),
            let saved = try? JSONDecoder().decode([ClosetRuling].self, from: data)
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
