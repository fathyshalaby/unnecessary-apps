import SwiftUI
import DumbKit

@main
struct DoorWasPushApp: App {
    var body: some Scene { WindowGroup { DoorWasPushView() } }
}

private enum DoorMistake: String, Codable, CaseIterable, Identifiable {
    case pulledPush
    case pushedPull
    case triedBoth

    var id: String { rawValue }
    var label: String {
        switch self {
        case .pulledPush: return "Pulled PUSH"
        case .pushedPull: return "Pushed PULL"
        case .triedBoth: return "Tried both"
        }
    }
    var shortLabel: String {
        switch self {
        case .pulledPush: return "PULL → PUSH"
        case .pushedPull: return "PUSH → PULL"
        case .triedBoth: return "BOTH WAYS"
        }
    }
    var symbol: String {
        switch self {
        case .pulledPush: return "arrow.left"
        case .pushedPull: return "arrow.right"
        case .triedBoth: return "arrow.left.and.right"
        }
    }
}

private struct DoorIncident: Codable, Identifiable {
    let id: UUID
    var place: String
    var mistake: DoorMistake
    var wrongAttempts: Int
    var signClarity: Int
    var note: String
    let occurredAt: Date
    var updatedAt: Date
}

struct DoorWasPushView: View {
    private static let waitingReport = "No architectural dispute on file. The doors currently deny everything."

    @AppStorage("doorLog.draft.place") private var place = ""
    @AppStorage("doorLog.draft.mistake") private var mistakeRaw = DoorMistake.pulledPush.rawValue
    @AppStorage("doorLog.draft.attempts") private var wrongAttempts = 1.0
    @AppStorage("doorLog.draft.clarity") private var signClarity = 3.0
    @AppStorage("doorLog.draft.note") private var note = ""
    @AppStorage("doorLog.history") private var storedHistory = "[]"
    @AppStorage("doorLog.report") private var latestReport = Self.waitingReport

    @State private var incidents: [DoorIncident] = []
    @State private var editingID: UUID?
    @State private var hasLoaded = false
    @State private var showAllHistory = false
    @State private var showEraseConfirmation = false
    @State private var incidentRevision = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let accent = CorpPalette.warningRed
    private let yellow = CorpPalette.sunshine

    var body: some View {
        DumbShell(
            eyebrow: "DOOR LITERACY INITIATIVE",
            title: "The door was push.",
            subtitle: "Log the real moment you fought architecture. Find out whether the signage—or you—has a pattern.",
            accent: accent,
            personality: .chaotic
        ) {
            filingCard

            DumbAction(
                title: editingID == nil ? "File door incident" : "Update door incident",
                accent: accent,
                systemImage: editingID == nil ? "door.left.hand.open" : "checkmark.seal.fill",
                action: saveIncident
            )
            .disabled(cleanPlace.isEmpty)
            .accessibilityIdentifier("saveDoorIncidentButton")

            if editingID != nil {
                Button("Cancel incident editing") { clearDraft() }
                    .font(.subheadline.weight(.black)).foregroundStyle(CorpPalette.mutedInk)
                .frame(maxWidth: .infinity, minHeight: 44)
                    .accessibilityIdentifier("cancelDoorIncidentEditingButton")
            }

            incidentReport
            DumbCharacterStage(
                accent: accent,
                title: "Independent door witness",
                caption: witnessCaption,
                reactionTrigger: incidentRevision,
                reactionStyle: .shake
            )
            lifetimeSummary
            historyCard

            Button { showEraseConfirmation = true } label: {
                Label("Erase complete door archive", systemImage: "trash.fill")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(incidents.isEmpty && !hasDraft && latestReport == Self.waitingReport)
            .accessibilityIdentifier("eraseDoorArchiveButton")
        }
        .onAppear(perform: restoreState)
        .confirmationDialog("Erase every door incident?", isPresented: $showEraseConfirmation, titleVisibility: .visible) {
            Button("Confirm erase complete door archive", role: .destructive, action: eraseAll)
            Button("Preserve the evidence", role: .cancel) {}
        } message: {
            Text("This erases every door report. It cannot be undone.")
        }
    }

    private var lifetimeSummary: some View {
        DumbCard(accent: accent, isSelected: !incidents.isEmpty) {
            HStack(spacing: 8) {
                metric("\(incidents.count)", "incidents")
                Divider()
                metric("\(totalWrongAttempts)", "attempts")
                Divider()
                metric("\(clearSignIncidents)", "clear signs")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Door incident summary")
        .accessibilityValue("\(incidents.count) incidents, \(totalWrongAttempts) wrong attempts, \(clearSignIncidents) clear signs ignored")
        .accessibilityIdentifier("doorIncidentSummary")
    }

    private func metric(_ value: String, _ label: String) -> some View {
        VStack(spacing: 3) {
            Text(value).font(.title3.weight(.black).monospacedDigit()).foregroundStyle(accent)
            Text(label.uppercased()).font(.caption2.weight(.black)).tracking(0.35).foregroundStyle(CorpPalette.mutedInk)
        }
        .frame(maxWidth: .infinity)
    }

    private var filingCard: some View {
        DumbCard(accent: accent, isSelected: !cleanPlace.isEmpty) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(editingID == nil ? "INCIDENT INTAKE" : "CORRECTING REPORT")
                        .font(.caption2.weight(.black).monospaced()).tracking(1.1).foregroundStyle(CorpPalette.mutedInk)
                    Spacer()
                    Text("INCIDENT").font(.caption2.weight(.black).monospaced()).foregroundStyle(accent)
                }

                DumbField("Door or place", maxLength: 100, text: $place)
                mistakePicker
                DumbSlider(title: "Wrong attempts", value: $wrongAttempts, range: 1...8, step: 1, accent: accent)
                DumbSlider(title: "Sign clarity", value: $signClarity, range: 1...5, step: 1, accent: yellow)
                HStack {
                    Text("1 = cryptic sculpture")
                    Spacer()
                    Text("5 = painfully obvious")
                }
                .font(.caption2.weight(.bold)).foregroundStyle(CorpPalette.mutedInk)
                DumbField("Optional note", axis: .vertical, maxLength: 240, text: $note)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Door incident form")
        .accessibilityValue("\(editingID == nil ? "New incident" : "Editing existing incident"), \(cleanPlace.isEmpty ? "No place" : cleanPlace), \(selectedMistake.label), \(Int(wrongAttempts)) wrong attempts, sign clarity \(Int(signClarity)) of 5")
        .accessibilityIdentifier("doorIncidentForm")
    }

    private var mistakePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text("WHAT DID THE SIGN MAKE YOU DO?")
                    .font(.caption2.weight(.black))
                    .tracking(0.8)
                    .foregroundStyle(CorpPalette.mutedInk)
                Spacer()
                Text(selectedMistake.shortLabel)
                    .font(.caption2.weight(.black).monospaced())
                    .foregroundStyle(accent)
            }
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                ForEach(DoorMistake.allCases) { option in
                    Button { mistakeRaw = option.rawValue } label: {
                        VStack(spacing: 6) {
                            Image(systemName: option.symbol)
                                .font(.headline.weight(.black))
                                .accessibilityHidden(true)
                            Text(option.shortLabel)
                                .font(.caption.weight(.black))
                                .minimumScaleFactor(0.78)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                        }
                        .foregroundStyle(selectedMistake == option ? CorpPalette.actionInk : CorpPalette.ink)
                        .frame(maxWidth: .infinity, minHeight: 62)
                        .padding(.horizontal, 7)
                        .background(selectedMistake == option ? accent : accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .stroke(selectedMistake == option ? accent : accent.opacity(0.12), lineWidth: selectedMistake == option ? 2 : 1)
                        }
                    }
                    .buttonStyle(DumbPressStyle())
                    .accessibilityLabel(option.label)
                    .accessibilityValue(selectedMistake == option ? "Selected" : "Not selected")
                    .accessibilityIdentifier("doorMistake\(option.rawValue)")
                }
            }
        }
    }

    private var incidentReport: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("DOOR INCIDENT REPORT").font(.caption.weight(.black).monospaced()).tracking(0.7)
                    Text("CASE \(caseNumber)").font(.caption2.weight(.bold).monospaced()).foregroundStyle(CorpPalette.mutedInk)
                }
                Spacer()
                doorDiagram
            }
            Rectangle().fill(accent).frame(height: 3)
            Text(latestReport).font(.system(.subheadline, design: .monospaced).weight(.bold)).foregroundStyle(CorpPalette.ink).fixedSize(horizontal: false, vertical: true)
            HStack { Text("WITNESS REPORT"); Spacer(); Text("ARCHITECTURE LOST") }
                .font(.caption2.weight(.black).monospaced()).foregroundStyle(CorpPalette.mutedInk)
        }
        .padding(19)
        .background {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(CorpPalette.surface)
                .shadow(color: accent.opacity(0.16), radius: 0, x: 4, y: 5)
        }
        .overlay(RoundedRectangle(cornerRadius: 9).stroke(accent, style: StrokeStyle(lineWidth: 2, dash: [4, 3])))
        .animation(reduceMotion ? nil : DumbMotion.quick, value: incidentRevision)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Door incident report")
        .accessibilityValue(latestReport)
        .accessibilityIdentifier("doorIncidentReport")
    }

    private var doorDiagram: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5).fill(accent.opacity(0.12)).frame(width: 44, height: 58)
            RoundedRectangle(cornerRadius: 5).stroke(accent, lineWidth: 2).frame(width: 44, height: 58)
            Circle().fill(accent).frame(width: 6, height: 6).offset(x: 14)
            Text("PUSH").font(.system(size: 7, weight: .black, design: .rounded)).foregroundStyle(accent).rotationEffect(.degrees(-90))
        }
        .rotationEffect(.degrees(incidentRevision > 0 && !reduceMotion ? -3 : 0))
        .accessibilityHidden(true)
    }

    private var historyCard: some View {
        DumbCard(accent: accent, isSelected: !incidents.isEmpty) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    DumbStatusPill("DOOR INCIDENTS", systemImage: "door.left.hand.closed", accent: accent)
                    Spacer()
                    Text("\(incidents.count) \(incidents.count == 1 ? "case" : "cases")")
                        .font(.caption.weight(.black)).foregroundStyle(CorpPalette.mutedInk)
                        .accessibilityIdentifier("doorHistoryCount").accessibilityValue("\(incidents.count)")
                }
                if incidents.isEmpty {
                    Label("No real door incident filed yet.", systemImage: "tray")
                        .font(.subheadline.weight(.bold)).foregroundStyle(CorpPalette.mutedInk)
                        .accessibilityIdentifier("emptyDoorHistory")
                } else {
                    Text(patternSummary).font(.caption.weight(.black)).foregroundStyle(accent).fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("doorPatternSummary")
                    ForEach(Array(visibleIncidents.enumerated()), id: \.element.id) { index, incident in
                        if index > 0 { Divider() }
                        historyRow(incident)
                    }
                    if incidents.count > 5 {
                        Button(showAllHistory ? "Show newest five" : "Browse all \(incidents.count) cases") { withAnimation(reduceMotion ? nil : .snappy) { showAllHistory.toggle() } }
                            .font(.subheadline.weight(.black)).foregroundStyle(accent)
                    }
                }
            }
        }
    }

    private func historyRow(_ incident: DoorIncident) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text(incident.place).font(.headline.weight(.black)).foregroundStyle(CorpPalette.ink)
                Spacer()
                Text(incident.mistake.shortLabel).font(.caption2.weight(.black)).foregroundStyle(accent)
            }
            Text("\(incident.wrongAttempts) wrong \(incident.wrongAttempts == 1 ? "attempt" : "attempts") · sign clarity \(incident.signClarity)/5")
                .font(.caption.weight(.semibold)).foregroundStyle(CorpPalette.mutedInk)
            if !incident.note.isEmpty {
                Text(incident.note).font(.caption.weight(.semibold)).foregroundStyle(CorpPalette.ink).lineLimit(3)
            }
            Text(incident.occurredAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2.weight(.bold)).foregroundStyle(CorpPalette.mutedInk)
            HStack(spacing: 18) {
                Button { edit(incident) } label: { Label("Edit door incident", systemImage: "pencil").font(.caption.weight(.black)) }
                Button(role: .destructive) { delete(incident) } label: { Label("Delete door incident", systemImage: "trash").font(.caption.weight(.black)) }
            }
        }
        .padding(.vertical, 3)
    }

    private var cleanPlace: String { place.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var cleanNote: String { note.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var selectedMistake: DoorMistake { DoorMistake(rawValue: mistakeRaw) ?? .pulledPush }
    private var hasDraft: Bool { !cleanPlace.isEmpty || selectedMistake != .pulledPush || Int(wrongAttempts) != 1 || Int(signClarity) != 3 || !cleanNote.isEmpty || editingID != nil }
    private var totalWrongAttempts: Int { incidents.reduce(0) { $0 + $1.wrongAttempts } }
    private var clearSignIncidents: Int { incidents.filter { $0.signClarity >= 4 }.count }
    private var visibleIncidents: [DoorIncident] { showAllHistory ? incidents : Array(incidents.prefix(5)) }
    private var caseNumber: String { String((editingID?.uuidString ?? incidents.first?.id.uuidString ?? "000000").prefix(6)) }
    private var witnessCaption: String {
        if let first = incidents.first { return "Latest evidence: \(first.place). The architecture has entered a statement." }
        return "No incident yet. Read the sign, then report only what actually happened."
    }
    private var patternSummary: String {
        let grouped = Dictionary(grouping: incidents, by: \.mistake).mapValues { $0.count }
        let common = DoorMistake.allCases.max { (grouped[$0] ?? 0) < (grouped[$1] ?? 0) } ?? .pulledPush
        return "Most common: \(common.label) (\(grouped[common] ?? 0) of \(incidents.count)). A pattern, according to one unreliable witness: you."
    }

    private func saveIncident() {
        guard !cleanPlace.isEmpty else { return }
        let now = Date()
        if let editingID, let index = incidents.firstIndex(where: { $0.id == editingID }) {
            incidents[index].place = cleanPlace
            incidents[index].mistake = selectedMistake
            incidents[index].wrongAttempts = Int(wrongAttempts)
            incidents[index].signClarity = Int(signClarity)
            incidents[index].note = cleanNote
            incidents[index].updatedAt = now
            latestReport = "CASE CORRECTED — \(cleanPlace): \(selectedMistake.label), \(Int(wrongAttempts)) wrong attempt\(Int(wrongAttempts) == 1 ? "" : "s"), clarity \(Int(signClarity))/5."
        } else {
            let incident = DoorIncident(
                id: UUID(), place: cleanPlace, mistake: selectedMistake,
                wrongAttempts: Int(wrongAttempts), signClarity: Int(signClarity),
                note: cleanNote, occurredAt: now, updatedAt: now
            )
            incidents.insert(incident, at: 0); incidents = Array(incidents.prefix(75))
            latestReport = "CASE FILED — \(cleanPlace): \(selectedMistake.label), \(incident.wrongAttempts) wrong attempt\(incident.wrongAttempts == 1 ? "" : "s"), clarity \(incident.signClarity)/5."
        }
        incidentRevision += 1; persistHistory(); clearDraft(keepReport: true)
    }

    private func edit(_ incident: DoorIncident) {
        editingID = incident.id; place = incident.place; mistakeRaw = incident.mistake.rawValue
        wrongAttempts = Double(incident.wrongAttempts); signClarity = Double(incident.signClarity); note = incident.note
        latestReport = "CORRECTION OPEN — editing \(incident.place). Saving updates this case instead of creating another."
    }
    private func delete(_ incident: DoorIncident) {
        incidents.removeAll { $0.id == incident.id }; if editingID == incident.id { clearDraft() }
        latestReport = incidents.isEmpty ? Self.waitingReport : "One door case was struck from the record."; persistHistory()
    }
    private func clearDraft(keepReport: Bool = false) {
        editingID = nil; place = ""; mistakeRaw = DoorMistake.pulledPush.rawValue; wrongAttempts = 1; signClarity = 3; note = ""
        if !keepReport { latestReport = incidents.isEmpty ? Self.waitingReport : "Correction cancelled. Existing door cases were not changed." }
    }
    private func eraseAll() {
        incidents = []; showAllHistory = false; clearDraft(); latestReport = Self.waitingReport; incidentRevision += 1; persistHistory()
    }
    private func restoreState() {
        guard !hasLoaded else { return }; hasLoaded = true
        if let data = storedHistory.data(using: .utf8), let decoded = try? JSONDecoder().decode([DoorIncident].self, from: data) { incidents = decoded }
    }
    private func persistHistory() {
        guard let data = try? JSONEncoder().encode(incidents), let encoded = String(data: data, encoding: .utf8) else { return }
        storedHistory = encoded
    }
}

#if canImport(PreviewsMacros)
#Preview { DoorWasPushView() }
#endif
