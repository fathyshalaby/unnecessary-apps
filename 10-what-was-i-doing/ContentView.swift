import SwiftUI
import DumbKit

private struct MemoryIncident: Codable, Identifiable {
    let id: UUID
    let date: Date
    let context: String
    let note: String

    init(date: Date = Date(), context: String, note: String) {
        id = UUID()
        self.date = date
        self.context = context
        self.note = note
    }

    private enum CodingKeys: String, CodingKey {
        case id, date, context, note
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        context = try container.decodeIfPresent(String.self, forKey: .context) ?? "Unspecified"
        note = try container.decodeIfPresent(String.self, forKey: .note) ?? ""
    }
}

struct WhatWasIDoingView: View {
    private static let incidentsKey = "whatWasIDoing.incidents"

    @State private var incidents: [MemoryIncident] = []
    @State private var lastEvent = "No incidents recorded. Suspiciously focused."
    @State private var hasLoaded = false
    @State private var context = "Opened phone"
    @State private var note = ""
    @State private var showEvidenceActions = false
    @AppStorage(Self.incidentsKey) private var storedIncidents = "[]"

    private let accent = CorpPalette.sleepyLavender
    private let calendar = Calendar.current
    private let contexts = ["Opened phone", "Entered a room", "Switched task", "Got interrupted", "Other"]

    var body: some View {
        AppCanvas(accent: accent, experience: .journal) {
            AppHeader(
                eyebrow: "MEMORY SERVICES",
                title: "What was I doing?",
                subtitle: "A tiny black box for when your purpose evaporates.",
                accent: accent
            )

            counterCard
            incidentEditor
            incidentLog

            DumbResult(
                text: lastEvent,
                accent: accent,
                systemImage: "brain.head.profile",
                reactionStyle: .bounce
            )
            .accessibilityIdentifier("memoryLogResult")

            Button {
                showEvidenceActions = true
            } label: {
                Label("Manage incidents", systemImage: "eraser.fill")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(incidents.isEmpty)
            .accessibilityIdentifier("resetEvidenceButton")
            .accessibilityHint("Opens controls to erase today’s incidents or the entire history.")
        } bottomBar: {
            DumbAction(
                title: "I forgot why",
                accent: accent,
                systemImage: "questionmark.diamond.fill",
                action: recordIncident
            )
            .accessibilityIdentifier("forgotButton")
        }
        .onAppear(perform: loadIncidents)
        .confirmationDialog(
            "What should disappear?",
            isPresented: $showEvidenceActions,
            titleVisibility: .visible
        ) {
            if todayCount > 0 {
                Button("Erase today's incidents", role: .destructive, action: clearToday)
            }
            Button("Erase all incident history", role: .destructive, action: clearAll)
            Button("Keep evidence", role: .cancel) {}
        } message: {
            Text("Deleted incidents cannot be restored.")
        }
    }

    private var incidentEditor: some View {
        DumbCard(accent: accent, isSelected: !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
            VStack(alignment: .leading, spacing: 14) {
                Text("FILE THE MOMENT")
                    .font(.caption2.weight(.black))
                    .tracking(1.2)
                    .foregroundStyle(CorpPalette.mutedInk)

                Picker("Where did the mission vanish?", selection: $context) {
                    ForEach(contexts, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(.menu)
                .font(.subheadline.weight(.black))
                .tint(accent)
                .accessibilityIdentifier("memoryContextPicker")

                DumbField(
                    "Last known mission (optional)",
                    axis: .vertical,
                    maxLength: 120,
                    text: $note
                )
                .accessibilityIdentifier("memoryNoteField")

                Text("Add a category and one sentence so Future You has a fighting chance.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
            }
        }
    }

    private var counterCard: some View {
        DumbCard(accent: accent, isSelected: todayCount > 0) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(accent.opacity(0.16))
                    Text("\(todayCount)")
                        .font(.system(.largeTitle, design: .rounded).weight(.black))
                        .minimumScaleFactor(0.62)
                        .lineLimit(1)
                        .foregroundStyle(accent)
                        .contentTransition(.numericText())
                        .monospacedDigit()
                }
                .frame(width: 86, height: 86)
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 5) {
                    DumbStatusPill(
                        todayCount == 0 ? "CLEAR RECORD" : "PURPOSE MISSING",
                        systemImage: todayCount == 0 ? "checkmark.seal.fill" : "exclamationmark.triangle.fill",
                        accent: accent
                    )
                    Text(todayCount == 0 ? "No lapses logged today." : "\(todayCount) moment\(todayCount == 1 ? "" : "s") of purpose lost today.")
                        .font(.headline.weight(.black))
                        .foregroundStyle(CorpPalette.ink)
                        .contentTransition(.opacity)
                    Text("Your incidents are waiting here for the next time your brain leaves the room.")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CorpPalette.mutedInk)
                    if let commonContext {
                        Text("Most common: \(commonContext)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(CorpPalette.mutedInk)
                            .accessibilityIdentifier("commonMemoryContext")
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("incidentCount")
        .accessibilityLabel("Today's forgotten moments")
        .accessibilityValue("\(todayCount)")
    }

    private var incidentLog: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("RECENT EVIDENCE")
                        .font(.caption2.weight(.black))
                        .tracking(1.2)
                        .foregroundStyle(CorpPalette.mutedInk)
                    Spacer()
                    Text("\(incidents.count) total")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .accessibilityIdentifier("incidentTotalCount")
                        .accessibilityValue("\(incidents.count)")
                }

                if recentIncidents.isEmpty {
                    Label("The log is beautifully empty.", systemImage: "sparkles")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(CorpPalette.ink)
                } else {
                    ForEach(recentIncidents) { incident in
                        VStack(alignment: .leading, spacing: 7) {
                            HStack(spacing: 10) {
                                Image(systemName: "clock.badge.questionmark")
                                    .foregroundStyle(accent)
                                    .accessibilityHidden(true)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(incident.context)
                                        .font(.subheadline.weight(.black))
                                        .foregroundStyle(CorpPalette.ink)
                                    Text(incident.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(CorpPalette.mutedInk)
                                }
                                Spacer()
                                Text(calendar.isDateInToday(incident.date) ? "TODAY" : "RECENT")
                                    .font(.caption2.weight(.black))
                                    .foregroundStyle(CorpPalette.mutedInk)
                            }

                            if !incident.note.isEmpty {
                                Text(incident.note)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(CorpPalette.ink)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Button(role: .destructive) {
                                delete(incident)
                            } label: {
                                Label("Delete incident", systemImage: "trash")
                                    .font(.caption.weight(.black))
                            }
                            .accessibilityIdentifier("deleteIncidentButton")
                        }
                        .padding(.vertical, 3)
                    }
                }
            }
        }
    }

    private var todayCount: Int {
        incidents.filter { calendar.isDateInToday($0.date) }.count
    }

    private var recentIncidents: [MemoryIncident] {
        Array(incidents.prefix(4))
    }

    private var commonContext: String? {
        guard !incidents.isEmpty else { return nil }
        let counts = Dictionary(grouping: incidents, by: \.context).mapValues { $0.count }
        return counts.max { lhs, rhs in
            if lhs.value == rhs.value { return lhs.key > rhs.key }
            return lhs.value < rhs.value
        }?.key
    }

    private func recordIncident() {
        let cleanNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        incidents.insert(MemoryIncident(context: context, note: cleanNote), at: 0)
        incidents = Array(incidents.prefix(100))
        lastEvent = cleanNote.isEmpty
            ? message(for: todayCount)
            : "Filed “\(cleanNote)” under \(context.lowercased())."
        note = ""
        persistIncidents()
    }

    private func clearToday() {
        incidents.removeAll { calendar.isDateInToday($0.date) }
        lastEvent = "Today's evidence has been professionally misplaced."
        persistIncidents()
    }

    private func clearAll() {
        incidents = []
        lastEvent = "The complete incident archive has been erased."
        persistIncidents()
    }

    private func delete(_ incident: MemoryIncident) {
        incidents.removeAll { $0.id == incident.id }
        lastEvent = "One incident was removed from the record."
        persistIncidents()
    }

    private func message(for count: Int) -> String {
        switch count {
        case 1: return "One lapse documented. The investigation begins."
        case 2...4: return "\(count) lapses. Your phone is becoming a decorative object."
        case 5...8: return "\(count) lapses. The wandering is now statistically interesting."
        default: return "\(count) lapses. Please locate the original mission."
        }
    }

    private func loadIncidents() {
        guard !hasLoaded else { return }
        hasLoaded = true
        guard
            let data = storedIncidents.data(using: .utf8),
            let saved = try? JSONDecoder().decode([MemoryIncident].self, from: data)
        else {
            return
        }
        incidents = saved.sorted { $0.date > $1.date }
    }

    private func persistIncidents() {
        guard let data = try? JSONEncoder().encode(incidents),
              let value = String(data: data, encoding: .utf8)
        else { return }
        storedIncidents = value
    }
}

#if canImport(PreviewsMacros)
#Preview { WhatWasIDoingView() }
#endif
