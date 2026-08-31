import SwiftUI
import DumbKit

private struct ChairCandidate: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let comfort: Int
    let shade: Int
    let pigeonRisk: Int
    let note: String
    let createdAt: Date

    var score: Int {
        (comfort * 2) + shade - pigeonRisk
    }
}

private enum ChairArchive {
    static let key = "chairFinder.candidates.v2"
    static let limit = 20

    static func load() -> [ChairCandidate] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([ChairCandidate].self, from: data) else {
            return []
        }
        return Array(decoded.prefix(limit))
    }

    static func save(_ candidates: [ChairCandidate]) {
        guard let data = try? JSONEncoder().encode(Array(candidates.prefix(limit))) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}

struct ChairFinderView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var candidates: [ChairCandidate]
    @State private var name = ""
    @State private var note = ""
    @State private var comfort = 6.0
    @State private var shade = 5.0
    @State private var pigeonRisk = 2.0
    @State private var validationMessage = ""
    @State private var inspectionRevision = 0
    @State private var showClearConfirmation = false

    @AppStorage("chairFinder.verdict.v2")
    private var verdict = "Add a chair you can actually see. The bureau refuses to invent furniture."
    @AppStorage("chairFinder.winnerID.v2")
    private var storedWinnerID = ""
    @AppStorage("chairFinder.inspections.v2")
    private var inspectionCount = 0

    private let accent = CorpPalette.parkGreen

    init() {
        _candidates = State(initialValue: ChairArchive.load())
    }

    private var winningChairID: UUID? {
        UUID(uuidString: storedWinnerID)
    }

    var body: some View {
        AppCanvas(accent: accent) {
            AppHeader(
                eyebrow: "MUNICIPAL SEATING BUREAU",
                title: "Chair Finder",
                subtitle: "Observe real chairs. File the evidence. Sit decisively.",
                accent: accent
            )

            HStack {
            DumbStatusPill("OFFICIAL CHAIR FILE", systemImage: "doc.text.fill", accent: accent)
            Spacer()
            Text("\(candidates.count)/\(ChairArchive.limit) OBSERVED")
            .font(.caption2.weight(.black))
            .tracking(0.8)
            .foregroundStyle(CorpPalette.mutedInk)
            .accessibilityIdentifier("chairCandidateCount")
            .accessibilityValue("\(candidates.count)")
            }

            candidateEditor

            if let winner = candidates.first(where: { $0.id == winningChairID }) {
            DumbCard(accent: accent, isSelected: true) {
            HStack(spacing: 12) {
            Image(systemName: "crown.fill")
            .font(.title2.weight(.black))
            .foregroundStyle(CorpPalette.verdictGold)
            .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
            Text("CURRENT WINNER")
            .font(.caption2.weight(.black))
            .tracking(1.1)
            .foregroundStyle(accent)
            Text("\(winner.name) · SIT \(winner.score)")
            .font(.headline.weight(.black))
            .foregroundStyle(CorpPalette.ink)
            }
            Spacer(minLength: 0)
            }
            }
            .accessibilityIdentifier("chairCurrentWinner")
            }

            candidateLedger

            Text("Build the shortlist from chairs you have actually seen. The bureau refuses to rank imaginary furniture.")
            .font(.caption.weight(.semibold))
            .foregroundStyle(CorpPalette.mutedInk)
            .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
            Button(action: resetRanking) {
            Label("Reset ranking", systemImage: "arrow.counterclockwise")
            .font(.subheadline.weight(.black))
            .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(storedWinnerID.isEmpty)
            .accessibilityIdentifier("resetChairFinderButton")

            Button {
            showClearConfirmation = true
            } label: {
            Image(systemName: "trash")
            .font(.headline.weight(.black))
            .frame(width: 48, height: 44)
            }
            .foregroundStyle(CorpPalette.warningRed)
            .buttonStyle(DumbPressStyle())
            .disabled(candidates.isEmpty)
            .accessibilityLabel("Clear all chair observations")
            .accessibilityIdentifier("clearChairCandidatesButton")
            }

        } bottomBar: {
            DumbAction(
            title: candidates.isEmpty ? "Add a chair before ranking" : "Rank my observed chairs",
            accent: accent,
            systemImage: "chair.lounge.fill",
            action: inspectChairs
            )
            .disabled(candidates.isEmpty)
            .accessibilityIdentifier("inspectChairButton")

            DumbResult(
            text: verdict,
            accent: accent,
            systemImage: "checkmark.seal.fill",
            reactionStyle: .bounce
            )
            .accessibilityIdentifier("chairVerdict")

        }
        .confirmationDialog(
            "Erase every chair observation?",
            isPresented: $showClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("Erase all chair observations", role: .destructive, action: clearAll)
            Button("Keep observations", role: .cancel) {}
        } message: {
            Text("This clears the shortlist and its current ranking. It cannot be undone.")
        }
    }

    private var candidateEditor: some View {
        DumbCard(accent: accent, isSelected: !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
            VStack(alignment: .leading, spacing: 14) {
                Text("FILE A REAL CHAIR")
                    .font(.caption2.weight(.black))
                    .tracking(1.2)
                    .foregroundStyle(accent)

                DumbField("Chair nickname", maxLength: 80, text: $name)
                    .accessibilityIdentifier("chairNameField")
                DumbSlider(title: "Comfort", value: $comfort, range: 0...10, accent: accent)
                    .accessibilityIdentifier("chairComfortSlider")
                DumbSlider(title: "Shade", value: $shade, range: 0...10, accent: accent)
                    .accessibilityIdentifier("chairShadeSlider")
                DumbSlider(title: "Pigeon risk", value: $pigeonRisk, range: 0...10, accent: accent)
                    .accessibilityIdentifier("chairPigeonSlider")
                DumbField("Optional field note", axis: .vertical, maxLength: 160, text: $note)
                    .accessibilityIdentifier("chairNoteField")

                if !validationMessage.isEmpty {
                    Label(validationMessage, systemImage: "exclamationmark.triangle.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CorpPalette.warningRed)
                        .accessibilityIdentifier("chairValidationMessage")
                }

                DumbAction(
                    title: candidates.count >= ChairArchive.limit ? "Archive full" : "Add observed chair",
                    accent: accent,
                    systemImage: "plus.circle.fill",
                    action: addCandidate
                )
                .disabled(candidates.count >= ChairArchive.limit)
                .accessibilityIdentifier("addChairCandidateButton")
            }
        }
    }

    @ViewBuilder
    private var candidateLedger: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("CHAIR SHORTLIST")
                    .font(.caption2.weight(.black))
                    .tracking(1.2)
                    .foregroundStyle(CorpPalette.mutedInk)
                Spacer()
                if inspectionCount > 0 {
                    DumbStatusPill("\(inspectionCount) RANKINGS", systemImage: "checkmark.seal", accent: accent)
                }
            }

            if candidates.isEmpty {
                DumbCard(accent: accent) {
                    HStack(spacing: 14) {
                        Image(systemName: "chair.lounge")
                            .font(.title.bold())
                            .foregroundStyle(accent)
                            .frame(width: 54, height: 54)
                            .background(accent.opacity(0.12), in: Circle())
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("No furniture testimony yet.")
                                .font(.headline.weight(.black))
                            Text("Look around, nickname a real chair, and rate what your body can verify.")
                                .font(.subheadline)
                                .foregroundStyle(CorpPalette.mutedInk)
                        }
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("emptyChairLedger")
            } else {
                ForEach(candidates) { candidate in
                    candidateCard(candidate)
                }
            }
        }
    }

    private func candidateCard(_ candidate: ChairCandidate) -> some View {
        DumbCard(accent: accent, isSelected: winningChairID == candidate.id) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 7) {
                            Text(candidate.name)
                                .font(.headline.weight(.black))
                            if winningChairID == candidate.id {
                                Image(systemName: "crown.fill")
                                    .foregroundStyle(CorpPalette.verdictGold)
                                    .accessibilityLabel("Current winner")
                            }
                        }
                        Text("Comfort \(candidate.comfort) · Shade \(candidate.shade) · Pigeons \(candidate.pigeonRisk)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CorpPalette.mutedInk)
                    }
                    Spacer(minLength: 8)
                    VStack(spacing: 0) {
                        Text("\(candidate.score)")
                            .font(.system(.title2, design: .rounded).weight(.black))
                            .foregroundStyle(accent)
                        Text("SIT")
                            .font(.caption2.weight(.black))
                            .tracking(0.8)
                            .foregroundStyle(CorpPalette.mutedInk)
                    }
                    .frame(width: 50, height: 50)
                    .background(accent.opacity(0.12), in: Circle())
                }

                if !candidate.note.isEmpty {
                    Text(candidate.note)
                        .font(.subheadline)
                        .foregroundStyle(CorpPalette.ink)
                }

                Button(role: .destructive) {
                    delete(candidate)
                } label: {
                    Label("Remove observation", systemImage: "trash")
                        .font(.caption.weight(.black))
                }
                .accessibilityIdentifier("deleteChair_\(candidate.id.uuidString)")
            }
        }
        .accessibilityIdentifier("chairCandidateCard")
    }

    private func addCandidate() {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else {
            validationMessage = "Give this chair a nickname before filing it."
            return
        }
        guard candidates.count < ChairArchive.limit else {
            validationMessage = "The archive is full. Remove a chair before adding another."
            return
        }

        let candidate = ChairCandidate(
            id: UUID(),
            name: cleanName,
            comfort: Int(comfort),
            shade: Int(shade),
            pigeonRisk: Int(pigeonRisk),
            note: cleanNote,
            createdAt: Date()
        )
        candidates.insert(candidate, at: 0)
        ChairArchive.save(candidates)
        name = ""
        note = ""
        comfort = 6
        shade = 5
        pigeonRisk = 2
        validationMessage = ""
        if !storedWinnerID.isEmpty {
            storedWinnerID = ""
            verdict = "Shortlist updated. Tap rank again for a fresh verdict."
        }
        inspectionRevision += 1
    }

    private func inspectChairs() {
        guard let winner = candidates.max(by: { lhs, rhs in
            if lhs.score == rhs.score {
                return lhs.createdAt > rhs.createdAt
            }
            return lhs.score < rhs.score
        }) else {
            verdict = "No chairs were filed. The bureau cannot rank a void."
            return
        }

        withAnimation(reduceMotion ? nil : DumbMotion.playful) {
            storedWinnerID = winner.id.uuidString
            inspectionCount += 1
            verdict = "Verdict: \(winner.name) wins with a SIT score of \(winner.score). Sit down before someone with a tote bag gets there."
            inspectionRevision += 1
        }
    }

    private func delete(_ candidate: ChairCandidate) {
        candidates.removeAll { $0.id == candidate.id }
        ChairArchive.save(candidates)
        if winningChairID == candidate.id {
            resetRanking()
        }
        inspectionRevision += 1
    }

    private func resetRanking() {
        storedWinnerID = ""
        verdict = candidates.isEmpty
            ? "Add a chair you can actually see. The bureau refuses to invent furniture."
            : "Shortlist saved. The bureau awaits a fresh ranking."
        inspectionRevision += 1
    }

    private func clearAll() {
        candidates = []
        ChairArchive.save([])
        inspectionCount = 0
        resetRanking()
    }
}

#if canImport(PreviewsMacros)
#Preview { ChairFinderView() }
#endif
