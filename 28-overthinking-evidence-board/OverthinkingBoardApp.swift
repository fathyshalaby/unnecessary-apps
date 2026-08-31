import SwiftUI
import DumbKit

private struct ReflectionCase: Codable, Identifiable {
    let id: UUID
    let worry: String
    let evidenceFor: String
    let evidenceAgainst: String
    let alternative: String
    let nextStep: String
    let conclusion: String
    let date: Date

    init(
        worry: String,
        evidenceFor: String,
        evidenceAgainst: String,
        alternative: String,
        nextStep: String,
        conclusion: String,
        date: Date = Date()
    ) {
        id = UUID()
        self.worry = worry
        self.evidenceFor = evidenceFor
        self.evidenceAgainst = evidenceAgainst
        self.alternative = alternative
        self.nextStep = nextStep
        self.conclusion = conclusion
        self.date = date
    }
}

@main
struct OverthinkingBoardApp: App {
    var body: some Scene { WindowGroup { OverthinkingBoardView().dumbNativeEntry(scheme: "app28overthinkingboard") { _, _ in } } }
}

struct OverthinkingBoardView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private static let emptyResult = "The board is empty. The detectives are relieved."

    @AppStorage("overthinkingBoard.worry") private var worry = ""
    @AppStorage("overthinkingBoard.evidenceFor") private var evidenceFor = ""
    @AppStorage("overthinkingBoard.evidence") private var evidenceAgainst = ""
    @AppStorage("overthinkingBoard.alternative") private var alternative = ""
    @AppStorage("overthinkingBoard.nextStep") private var nextStep = ""
    @AppStorage("overthinkingBoard.result") private var result = Self.emptyResult
    @AppStorage("overthinkingBoard.cases") private var storedCases = "[]"

    @State private var cases: [ReflectionCase] = []
    @State private var hasLoaded = false
    @State private var showAllCases = false
    @State private var showArchiveActions = false
    @State private var evidenceSectionsExpanded = false

    private let accent = CorpPalette.evidenceMint
    private let warningAccent = CorpPalette.emergencyRed

    var body: some View {
        DumbShell(
            eyebrow: "PERSONAL INVESTIGATIONS",
            title: "Overthinking evidence board",
            subtitle: "Not therapy. Just a corkboard with better typography.",
            accent: accent,
            personality: .dramatic
        ) {
            safetyCard
            boardEditor

            DumbAction(
                title: "Issue a provisional conclusion",
                accent: accent,
                systemImage: "magnifyingglass",
                action: issueConclusion
            )
            .disabled(cleanWorry.isEmpty)
            .accessibilityIdentifier("issueConclusionButton")

            DumbResult(
                text: result,
                accent: accent,
                systemImage: "pin.fill",
                reactionStyle: .stamp
            )
            .accessibilityIdentifier("overthinkingResult")

            Button(action: clearCurrentBoard) {
                Label("Clear current board", systemImage: "rectangle.portrait.and.arrow.right")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(!hasCurrentBoard)
            .accessibilityIdentifier("clearOverthinkingButton")
            .accessibilityHint("Clears the current draft without deleting archived cases.")

            caseArchive

            Button {
                showArchiveActions = true
            } label: {
                Label("Manage case files", systemImage: "archivebox.fill")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(cases.isEmpty)
            .accessibilityIdentifier("manageOverthinkingArchiveButton")

            DumbNativeTip(
                "Share from anywhere",
                detail: "Share selected text from Notes or Messages to pin it on the evidence board.",
                systemImage: "square.and.arrow.down",
                accent: accent
            )
        }
        .onAppear {
            restoreCases()
            if let shared = DumbSharedPayload.consume(for: .overthinking) {
                worry = shared
                evidenceSectionsExpanded = true
            }
        }
        .onChange(of: worry) { _, newValue in
            if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                evidenceSectionsExpanded = true
            }
            invalidateConclusion()
        }
        .onChange(of: evidenceFor) { _, _ in invalidateConclusion() }
        .onChange(of: evidenceAgainst) { _, _ in invalidateConclusion() }
        .onChange(of: alternative) { _, _ in invalidateConclusion() }
        .onChange(of: nextStep) { _, _ in invalidateConclusion() }
        .confirmationDialog(
            "Case-file services",
            isPresented: $showArchiveActions,
            titleVisibility: .visible
        ) {
            Button("Erase all archived cases", role: .destructive, action: clearArchive)
            Button("Keep the files", role: .cancel) {}
        } message: {
            Text("This erases every archived case. It cannot be undone.")
        }
    }

    private var safetyCard: some View {
        DumbCard(accent: warningAccent) {
            VStack(alignment: .leading, spacing: 7) {
                DumbStatusPill(
                    "EVERYDAY WORRIES ONLY",
                    systemImage: "exclamationmark.shield.fill",
                    accent: warningAccent
                )
                Text("This board sorts the evidence you enter. It is a thinking tool, not a truth machine or crisis service.")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CorpPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var boardEditor: some View {
        DumbCard(accent: accent, isSelected: !cleanWorry.isEmpty) {
            VStack(alignment: .leading, spacing: 13) {
                Text("PIN THE CASE")
                    .font(.caption2.weight(.black))
                    .tracking(1.2)
                    .foregroundStyle(CorpPalette.mutedInk)

                DumbField("The worry", axis: .vertical, maxLength: 240, text: $worry)

                if !cleanWorry.isEmpty {
                    DisclosureGroup(isExpanded: $evidenceSectionsExpanded) {
                        VStack(alignment: .leading, spacing: 13) {
                            DumbField("Evidence supporting it", axis: .vertical, maxLength: 240, text: $evidenceFor)
                            DumbField("Evidence against it", axis: .vertical, maxLength: 240, text: $evidenceAgainst)
                            DumbField("A less dramatic explanation", axis: .vertical, maxLength: 240, text: $alternative)
                            DumbField("One small next step", axis: .vertical, maxLength: 160, text: $nextStep)
                        }
                        .padding(.top, 8)
                    } label: {
                        Label(
                            evidenceSectionsExpanded ? "Hide evidence sections" : "Add supporting and counter evidence",
                            systemImage: "pin.fill"
                        )
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(CorpPalette.ink)
                    }
                } else {
                    Text("Start with the worry. The evidence corkboard opens once you name it.")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CorpPalette.mutedInk)
                }

                Text("Drafts stay on the board until you file or erase them.")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CorpPalette.mutedInk)
            }
        }
    }

    private var caseArchive: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("CASE FILES")
                        .font(.caption2.weight(.black))
                        .tracking(1.2)
                        .foregroundStyle(CorpPalette.mutedInk)
                    Spacer()
                    Text("\(cases.count) archived")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .accessibilityIdentifier("overthinkingArchiveCount")
                        .accessibilityValue("\(cases.count)")
                }

                if cases.isEmpty {
                    Label("No closed cases. Remarkably peaceful.", systemImage: "archivebox")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(CorpPalette.ink)
                        .accessibilityIdentifier("emptyOverthinkingArchive")
                } else {
                    ForEach(visibleCases) { savedCase in
                        VStack(alignment: .leading, spacing: 7) {
                            HStack {
                                DumbStatusPill(
                                    status(for: savedCase.evidenceFor, against: savedCase.evidenceAgainst).uppercased(),
                                    systemImage: "pin.fill",
                                    accent: accent
                                )
                                Spacer()
                                Text(savedCase.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(CorpPalette.mutedInk)
                            }
                            Text(savedCase.worry)
                                .font(.headline.weight(.black))
                                .foregroundStyle(CorpPalette.ink)
                                .fixedSize(horizontal: false, vertical: true)
                            if !savedCase.nextStep.isEmpty {
                                Text("Next: \(savedCase.nextStep)")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(CorpPalette.ink)
                            }
                            Button(role: .destructive) {
                                delete(savedCase)
                            } label: {
                                Label("Delete case file", systemImage: "trash")
                                    .font(.caption.weight(.black))
                            }
                            .accessibilityIdentifier("deleteOverthinkingCaseButton")
                        }
                        .padding(.vertical, 3)
                    }

                    if cases.count > 5 {
                        Button(showAllCases ? "Show newest five" : "Browse all \(cases.count)") {
                            withAnimation(reduceMotion ? nil : .snappy) {
                                showAllCases.toggle()
                            }
                        }
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(accent)
                        .accessibilityIdentifier("toggleOverthinkingHistoryButton")
                    }
                }
            }
        }
    }

    private var cleanWorry: String {
        worry.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var cleanEvidenceFor: String {
        evidenceFor.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var cleanEvidenceAgainst: String {
        evidenceAgainst.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var cleanAlternative: String {
        alternative.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var cleanNextStep: String {
        nextStep.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var hasCurrentBoard: Bool {
        !cleanWorry.isEmpty
            || !cleanEvidenceFor.isEmpty
            || !cleanEvidenceAgainst.isEmpty
            || !cleanAlternative.isEmpty
            || !cleanNextStep.isEmpty
            || result != Self.emptyResult
    }

    private var visibleCases: [ReflectionCase] {
        showAllCases ? cases : Array(cases.prefix(5))
    }

    private func issueConclusion() {
        guard !cleanWorry.isEmpty else { return }

        let caseStatus = status(for: cleanEvidenceFor, against: cleanEvidenceAgainst)
        let support = cleanEvidenceFor.isEmpty ? "No supporting evidence entered." : cleanEvidenceFor
        let counter = cleanEvidenceAgainst.isEmpty ? "No counter-evidence entered." : cleanEvidenceAgainst
        let alternate = cleanAlternative.isEmpty ? "No alternative explanation entered." : cleanAlternative
        let action = cleanNextStep.isEmpty ? "No next step entered." : cleanNextStep
        let conclusion = """
        Status: \(caseStatus).
        Supporting evidence: \(support)
        Counter-evidence: \(counter)
        Alternative: \(alternate)
        Next small step: \(action)
        This is a writing prompt, not a truth or safety assessment.
        """
        result = conclusion

        let savedCase = ReflectionCase(
            worry: cleanWorry,
            evidenceFor: cleanEvidenceFor,
            evidenceAgainst: cleanEvidenceAgainst,
            alternative: cleanAlternative,
            nextStep: cleanNextStep,
            conclusion: conclusion
        )
        if !matchesCurrentCase(cases.first, savedCase) {
            cases.insert(savedCase, at: 0)
            cases = Array(cases.prefix(50))
            persistCases()
        }
    }

    private func status(for supporting: String, against counter: String) -> String {
        switch (supporting.isEmpty, counter.isEmpty) {
        case (true, true):
            return "Case unproven"
        case (true, false):
            return "Case weakened"
        case (false, true):
            return "Counter-evidence missing"
        case (false, false):
            return "Evidence mixed"
        }
    }

    private func matchesCurrentCase(_ existing: ReflectionCase?, _ candidate: ReflectionCase) -> Bool {
        guard let existing else { return false }
        return existing.worry == candidate.worry
            && existing.evidenceFor == candidate.evidenceFor
            && existing.evidenceAgainst == candidate.evidenceAgainst
            && existing.alternative == candidate.alternative
            && existing.nextStep == candidate.nextStep
    }

    private func invalidateConclusion() {
        result = cleanWorry.isEmpty
            ? Self.emptyResult
            : "Board changed. Issue a fresh provisional conclusion."
    }

    private func clearCurrentBoard() {
        worry = ""
        evidenceFor = ""
        evidenceAgainst = ""
        alternative = ""
        nextStep = ""
        result = Self.emptyResult
        evidenceSectionsExpanded = false
    }

    private func delete(_ savedCase: ReflectionCase) {
        cases.removeAll { $0.id == savedCase.id }
        persistCases()
    }

    private func clearArchive() {
        cases = []
        showAllCases = false
        persistCases()
    }

    private func restoreCases() {
        guard !hasLoaded else { return }
        hasLoaded = true
        guard
            let data = storedCases.data(using: .utf8),
            let saved = try? JSONDecoder().decode([ReflectionCase].self, from: data)
        else {
            return
        }
        cases = saved.sorted { $0.date > $1.date }
    }

    private func persistCases() {
        guard
            let data = try? JSONEncoder().encode(cases),
            let value = String(data: data, encoding: .utf8)
        else {
            return
        }
        storedCases = value
    }
}
