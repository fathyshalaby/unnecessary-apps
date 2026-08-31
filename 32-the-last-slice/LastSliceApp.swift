import SwiftUI
import DumbKit

@main
struct LastSliceApp: App {
    var body: some Scene { WindowGroup { LastSliceView().dumbNativeEntry(scheme: "app32lastslice") { _, _ in } } }
}

private struct SliceRuling: Codable, Identifiable {
    let id: UUID
    let item: String
    let participants: [String]
    var remaining: [String]
    var candidate: String
    var passes: [String]
    let startedAt: Date
}

private enum SliceOutcome: String, Codable {
    case awarded
    case unclaimed
}

private struct SliceRecord: Codable, Identifiable {
    let id: UUID
    let item: String
    let participants: [String]
    let winner: String?
    let passes: [String]
    let decidedAt: Date
    let outcome: SliceOutcome
}

struct LastSliceView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private static let waitingTreaty = "No ruling yet. Add the actual people at the table to convene a fair tribunal."

    @AppStorage("lastSlice.draft.people") private var names = ""
    @AppStorage("lastSlice.draft.item") private var itemName = "Last slice"
    @AppStorage("lastSlice.active") private var storedActive = ""
    @AppStorage("lastSlice.history") private var storedHistory = "[]"
    @AppStorage("lastSlice.treaty") private var treatyText = Self.waitingTreaty

    @State private var activeRuling: SliceRuling?
    @State private var history: [SliceRecord] = []
    @State private var hasLoaded = false
    @State private var showAllHistory = false
    @State private var showEraseConfirmation = false

    private let accent = CorpPalette.warningRed
    private let gold = CorpPalette.sunshine

    var body: some View {
        AppCanvas(accent: accent) {
            AppHeader(
                eyebrow: "SHARED FOOD DIPLOMACY",
                title: "Who gets the last one?",
                subtitle: "A tiny fairness protocol for snacks, seats, chores, and other fragile alliances.",
                accent: accent
            )

            DumbBoundaryChip(
                storageKey: "lastSlice.boundaryDismissed",
                message: "Fairness theater for your group — not legal arbitration or payment splitting.",
                accent: accent,
                systemImage: "fork.knife"
            )

            fairnessRule
            rulingSummary

            if let activeRuling {
            tribunalCard(activeRuling)
            } else {
            rosterCard

            }

            treatyCard

            if treatyText != Self.waitingTreaty {
                DumbShareVerdict(
                    text: treatyText,
                    subject: "Last slice treaty",
                    accent: accent,
                    accessibilityIdentifier: "shareSliceTreatyButton"
                )
            }

            historyCard

            Button { showEraseConfirmation = true } label: {
            Label("Erase complete diplomacy archive", systemImage: "trash.fill")
            .font(.subheadline.weight(.black))
            .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(activeRuling == nil && history.isEmpty && !hasDraft && treatyText == Self.waitingTreaty)
            .accessibilityIdentifier("eraseSliceArchiveButton")

        } bottomBar: {
            if activeRuling != nil {
                HStack(spacing: 10) {
                    Button { candidatePassed() } label: {
                        Label("They passed", systemImage: "hand.raised.fill")
                            .font(.subheadline.weight(.black))
                            .frame(maxWidth: .infinity, minHeight: DumbMetrics.minimumTapTarget)
                    }
                    .buttonStyle(.bordered)
                    .tint(accent)
                    .accessibilityIdentifier("sliceCandidatePassedButton")

                    Button { awardCandidate() } label: {
                        Label("Award it", systemImage: "checkmark.seal.fill")
                            .font(.subheadline.weight(.black))
                            .frame(maxWidth: .infinity, minHeight: DumbMetrics.minimumTapTarget)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(accent)
                    .accessibilityIdentifier("sliceAwardButton")
                }
            } else {
                DumbAction(
                    title: "Convene fair tribunal",
                    accent: accent,
                    systemImage: "scale.3d",
                    action: startRuling
                )
                .disabled(cleanItem.isEmpty || people.count < 2)
                .accessibilityIdentifier("resolveSliceButton")
            }

        }
        .onAppear(perform: restoreState)
        .confirmationDialog("Erase active ruling and all diplomacy history?", isPresented: $showEraseConfirmation, titleVisibility: .visible) {
            Button("Confirm erase complete diplomacy archive", role: .destructive, action: eraseAll)
            Button("Keep the treaty", role: .cancel) {}
        } message: {
            Text("This erases the roster, current ruling, and complete history. It cannot be undone.")
        }
    }

    private var fairnessRule: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 9) {
                DumbStatusPill("PUBLISHED FAIRNESS RULE", systemImage: "equal.circle.fill", accent: accent)
                Text("The fewest previous wins go first. If there’s a tie, fate picks. Passing skips one person for this round.")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CorpPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Fair rotation, not destiny. Correct the roster before convening.")
                    .font(.caption.weight(.black))
                    .foregroundStyle(CorpPalette.mutedInk)
            }
        }
    }

    private var rulingSummary: some View {
        DumbCard(accent: accent, isSelected: !history.isEmpty) {
            HStack(spacing: 8) {
                metric("\(history.count)", "rulings")
                Divider()
                metric("\(awardedCount)", "awarded")
                Divider()
                metric("\(totalPasses)", "passes")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Diplomacy history summary")
        .accessibilityValue("\(history.count) rulings, \(awardedCount) awarded, \(totalPasses) passes")
        .accessibilityIdentifier("sliceHistorySummary")
    }

    private func metric(_ value: String, _ label: String) -> some View {
        VStack(spacing: 3) {
            Text(value).font(.title3.weight(.black).monospacedDigit()).foregroundStyle(accent)
            Text(label.uppercased()).font(.caption2.weight(.black)).tracking(0.4).foregroundStyle(CorpPalette.mutedInk)
        }
        .frame(maxWidth: .infinity)
    }

    private var rosterCard: some View {
        DumbCard(accent: accent, isSelected: people.count >= 2) {
            VStack(alignment: .leading, spacing: 13) {
                Text("DRAFT THE TREATY").font(.caption2.weight(.black).monospaced()).tracking(1.1).foregroundStyle(CorpPalette.mutedInk)
                DumbField("Item to award", maxLength: 80, text: $itemName)
                DumbField("People involved", maxLength: 240, text: $names)
                Text("Separate names with commas. We’ll clean up duplicates and blanks.")
                    .font(.caption.weight(.semibold)).foregroundStyle(CorpPalette.mutedInk)

                if people.isEmpty {
                    DumbEmptyInvite(
                        title: "No eligible people yet",
                        message: "Separate names with commas — at least two people to convene the tribunal.",
                        systemImage: "person.2.slash",
                        accent: accent
                    )
                    .accessibilityIdentifier("emptySliceRoster")
                } else {
                    participantChips(people)
                }

                Text("\(people.count) eligible \(people.count == 1 ? "person" : "people")")
                    .font(.caption.weight(.black)).foregroundStyle(accent)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .accessibilityLabel("Eligible people")
                    .accessibilityValue("\(people.count)")
                    .accessibilityIdentifier("sliceEligibleCount")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Last item roster")
        .accessibilityValue("\(people.count) eligible people")
        .accessibilityIdentifier("slicePeopleInput")
    }

    private func participantChips(_ participants: [String]) -> some View {
        let rows = stride(from: 0, to: participants.count, by: 2).map { Array(participants[$0..<min($0 + 2, participants.count)]) }
        return VStack(spacing: 7) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 7) {
                    ForEach(row, id: \.self) { name in
                        HStack(spacing: 5) {
                            Circle().fill(accent).frame(width: 7, height: 7)
                            Text(name).font(.caption.weight(.black)).lineLimit(1)
                            Text("\(awardCount(for: name))").font(.caption2.weight(.black).monospacedDigit()).foregroundStyle(accent)
                        }
                        .padding(.horizontal, 10).padding(.vertical, 7)
                        .frame(maxWidth: .infinity)
                        .background(accent.opacity(0.09), in: Capsule())
                    }
                    if row.count == 1 { Spacer().frame(maxWidth: .infinity) }
                }
            }
        }
    }

    private func tribunalCard(_ ruling: SliceRuling) -> some View {
        DumbCard(accent: accent, isSelected: true) {
            VStack(alignment: .leading, spacing: 15) {
                tribunalHeader(ruling)
                candidatePanel(ruling)
                participantChips(ruling.remaining)
                Button("Cancel this ruling") { cancelRuling() }
                    .font(.caption.weight(.black)).foregroundStyle(CorpPalette.mutedInk)
                    .frame(maxWidth: .infinity)
                    .accessibilityIdentifier("cancelSliceRulingButton")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Active last item tribunal")
        .accessibilityValue("Candidate \(ruling.candidate), \(ruling.passes.count) passes")
        .accessibilityIdentifier("activeSliceRuling")
    }

    private func tribunalHeader(_ ruling: SliceRuling) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("TRIBUNAL IN SESSION")
                    .font(.caption2.weight(.black).monospaced())
                    .tracking(1.1)
                    .foregroundStyle(CorpPalette.mutedInk)
                Text(ruling.item).font(.title3.weight(.black)).foregroundStyle(CorpPalette.ink)
            }
            Spacer()
            Image(systemName: "seal.fill")
                .font(.largeTitle)
                .foregroundStyle(accent)
                .accessibilityHidden(true)
        }
    }

    private func candidatePanel(_ ruling: SliceRuling) -> some View {
        VStack(spacing: 4) {
            Text("CURRENT CANDIDATE")
                .font(.caption2.weight(.black))
                .tracking(1)
                .foregroundStyle(CorpPalette.mutedInk)
            Text(ruling.candidate)
                .font(.system(.largeTitle, design: .rounded).weight(.black))
                .foregroundStyle(accent)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text("Fewest prior awards among the remaining eligible people.")
                .font(.caption.weight(.bold))
                .foregroundStyle(CorpPalette.mutedInk)
                .multilineTextAlignment(.center)
        }
        .padding(17)
        .frame(maxWidth: .infinity)
        .background(gold.opacity(0.18), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Current candidate")
        .accessibilityValue(ruling.candidate)
        .accessibilityIdentifier("sliceCurrentCandidate")
    }

    private var treatyCard: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("DIPLOMATIC COMMUNIQUÉ").font(.caption.weight(.black).monospaced()).tracking(0.7)
                    Text("FILE \(treatyNumber)").font(.caption2.weight(.bold).monospaced()).foregroundStyle(CorpPalette.mutedInk)
                }
                Spacer()
                Image(systemName: "scroll.fill").font(.largeTitle.weight(.black)).foregroundStyle(accent).rotationEffect(.degrees(5)).accessibilityHidden(true)
            }
            Rectangle().fill(accent).frame(height: 3)
            Text(treatyText).font(.system(.subheadline, design: .serif).weight(.bold)).foregroundStyle(CorpPalette.ink).fixedSize(horizontal: false, vertical: true)
            HStack { Text("FAIR RULING"); Spacer(); Text("GROUP DRAMA") }
                .font(.caption2.weight(.black).monospaced()).foregroundStyle(CorpPalette.mutedInk)
        }
        .padding(19)
        .background(CorpPalette.surface, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 9).stroke(accent, style: StrokeStyle(lineWidth: 2, dash: [7, 3])))
        .shadow(color: accent.opacity(0.16), radius: 0, x: 4, y: 5)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Diplomatic communiqué")
        .accessibilityValue(treatyText)
        .accessibilityIdentifier("sliceTreaty")
    }

    private var historyCard: some View {
        DumbCard(accent: accent, isSelected: !history.isEmpty) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    DumbStatusPill("RULING LEDGER", systemImage: "books.vertical.fill", accent: accent)
                    Spacer()
                    Text("\(history.count) \(history.count == 1 ? "ruling" : "rulings")")
                        .font(.caption.weight(.black)).foregroundStyle(CorpPalette.mutedInk)
                        .accessibilityIdentifier("sliceHistoryCount").accessibilityValue("\(history.count)")
                }
                if history.isEmpty {
                    DumbEmptyInvite(
                        title: "No completed ruling yet",
                        message: "Convene a tribunal and ratify a treaty to start the archive.",
                        systemImage: "tray",
                        accent: accent
                    )
                    .accessibilityIdentifier("emptySliceHistory")
                } else {
                    ForEach(Array(visibleHistory.enumerated()), id: \.element.id) { index, record in
                        if index > 0 { Divider() }
                        historyRow(record)
                    }
                    if history.count > 5 {
                        Button(showAllHistory ? "Show newest five" : "Browse all \(history.count) rulings") { withAnimation(reduceMotion ? nil : .snappy) { showAllHistory.toggle() } }
                            .font(.subheadline.weight(.black)).foregroundStyle(accent)
                    }
                }
            }
        }
    }

    private func historyRow(_ record: SliceRecord) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(record.item).font(.headline.weight(.black)).foregroundStyle(CorpPalette.ink)
                Spacer()
                Text(record.outcome == .awarded ? "AWARDED" : "UNCLAIMED")
                    .font(.caption2.weight(.black)).foregroundStyle(record.outcome == .awarded ? CorpPalette.parkGreen : accent)
            }
            Text(record.winner.map { "\($0) received it" } ?? "Everybody passed")
                .font(.subheadline.weight(.black)).foregroundStyle(accent)
            Text("\(record.participants.count) eligible · \(record.passes.count) passed · \(record.decidedAt.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption.weight(.semibold)).foregroundStyle(CorpPalette.mutedInk)
            Button(role: .destructive) { delete(record) } label: {
                Label("Delete slice ruling", systemImage: "trash").font(.caption.weight(.black))
            }
        }
        .padding(.vertical, 3)
    }

    private var cleanItem: String { itemName.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var people: [String] {
        var seen = Set<String>()
        return names.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .filter { seen.insert($0.lowercased()).inserted }
            .prefix(20).map { $0 }
    }
    private var hasDraft: Bool { !names.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || cleanItem != "Last slice" }
    private var visibleHistory: [SliceRecord] { showAllHistory ? history : Array(history.prefix(5)) }
    private var awardedCount: Int { history.filter { $0.outcome == .awarded }.count }
    private var totalPasses: Int { history.reduce(0) { $0 + $1.passes.count } }
    private var treatyNumber: String { String((activeRuling?.id.uuidString ?? history.first?.id.uuidString ?? "000000").prefix(6)) }

    private func normalized(_ name: String) -> String { name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
    private func awardCount(for name: String) -> Int {
        history.filter { record in record.winner.map { normalized($0) } == normalized(name) }.count
    }
    private func fairCandidate(from eligible: [String]) -> String {
        let minimum = eligible.map { awardCount(for: $0) }.min() ?? 0
        return eligible.filter { awardCount(for: $0) == minimum }.randomElement() ?? eligible[0]
    }

    private func startRuling() {
        guard people.count >= 2, !cleanItem.isEmpty else { return }
        let candidate = fairCandidate(from: people)
        let ruling = SliceRuling(id: UUID(), item: cleanItem, participants: people, remaining: people, candidate: candidate, passes: [], startedAt: Date())
        activeRuling = ruling
        treatyText = "TRIBUNAL CONVENED — \(candidate) is first candidate for \(cleanItem). The selection used the published fewest-awards rule."
        persistActive()
    }

    private func candidatePassed() {
        guard var ruling = activeRuling else { return }
        ruling.passes.append(ruling.candidate)
        ruling.remaining.removeAll { normalized($0) == normalized(ruling.candidate) }
        guard !ruling.remaining.isEmpty else {
            finish(ruling, winner: nil)
            return
        }
        ruling.candidate = fairCandidate(from: ruling.remaining)
        activeRuling = ruling
        treatyText = "PASS RECORDED — the tribunal now recognizes \(ruling.candidate) as candidate. \(ruling.remaining.count) remain eligible this round."
        persistActive()
    }

    private func awardCandidate() {
        guard let ruling = activeRuling else { return }
        finish(ruling, winner: ruling.candidate)
    }

    private func finish(_ ruling: SliceRuling, winner: String?) {
        let record = SliceRecord(
            id: ruling.id, item: ruling.item, participants: ruling.participants, winner: winner,
            passes: ruling.passes, decidedAt: Date(), outcome: winner == nil ? .unclaimed : .awarded
        )
        history.insert(record, at: 0); history = Array(history.prefix(50)); activeRuling = nil
        treatyText = winner.map { "TREATY RATIFIED — \($0) receives \(record.item). \(record.passes.count) diplomatic pass\(record.passes.count == 1 ? "" : "es") recorded." }
            ?? "DIPLOMATIC IMMUNITY — everybody passed on \(record.item). No award was counted."
        persistActive(); persistHistory()
    }

    private func cancelRuling() {
        activeRuling = nil; treatyText = "RULING CANCELLED — no award or pass was added to history."; persistActive()
    }
    private func delete(_ record: SliceRecord) {
        history.removeAll { $0.id == record.id }; treatyText = history.isEmpty ? Self.waitingTreaty : "One completed ruling was struck from the record."; persistHistory()
    }
    private func eraseAll() {
        activeRuling = nil; history = []; names = ""; itemName = "Last slice"; treatyText = Self.waitingTreaty; showAllHistory = false; persistActive(); persistHistory()
    }
    private func restoreState() {
        guard !hasLoaded else { return }; hasLoaded = true
        if let data = storedActive.data(using: .utf8), let decoded = try? JSONDecoder().decode(SliceRuling.self, from: data) { activeRuling = decoded }
        if let data = storedHistory.data(using: .utf8), let decoded = try? JSONDecoder().decode([SliceRecord].self, from: data) { history = decoded }
    }
    private func persistActive() {
        guard let activeRuling else { storedActive = ""; return }
        guard let data = try? JSONEncoder().encode(activeRuling), let encoded = String(data: data, encoding: .utf8) else { return }
        storedActive = encoded
    }
    private func persistHistory() {
        guard let data = try? JSONEncoder().encode(history), let encoded = String(data: data, encoding: .utf8) else { return }
        storedHistory = encoded
    }
}

#if canImport(PreviewsMacros)
#Preview { LastSliceView() }
#endif
