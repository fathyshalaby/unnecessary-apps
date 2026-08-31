import SwiftUI
import DumbKit
#if canImport(ActivityKit)
import ActivityKit
#endif

@main
struct WalkingMeetingApp: App {
    var body: some Scene { WindowGroup { WalkingMeetingView().dumbNativeEntry(scheme: "app42walkingmeeting") { _, _ in } } }
}

private enum WalkCheckpoint: String, Codable, CaseIterable, Identifiable {
    case objective
    case decision
    case nextStep

    var id: String { rawValue }
    var label: String {
        switch self {
        case .objective: return "Objective stated"
        case .decision: return "Decision captured"
        case .nextStep: return "Next step assigned"
        }
    }
    var symbol: String {
        switch self {
        case .objective: return "scope"
        case .decision: return "checkmark.seal.fill"
        case .nextStep: return "figure.walk.motion"
        }
    }
}

private struct WalkNote: Codable, Identifiable {
    let id: UUID
    let text: String
    let secondsFromStart: Int
}

private struct ActiveWalkingMeeting: Codable, Identifiable {
    let id: UUID
    let title: String
    let objective: String
    let routeContext: String
    let plannedMinutes: Int
    let startedAt: Date
    let reminderEnabled: Bool
    var completedCheckpoints: [WalkCheckpoint]
    var notes: [WalkNote]
}

private enum WalkOutcome: String, Codable {
    case completed
    case endedEarly

    var label: String { self == .completed ? "COMPLETED" : "ENDED EARLY" }
}

private struct WalkingMeetingRecord: Codable, Identifiable {
    let id: UUID
    let title: String
    let objective: String
    let routeContext: String
    let plannedMinutes: Int
    let actualSeconds: Int
    let completedCheckpoints: [WalkCheckpoint]
    let notes: [WalkNote]
    let startedAt: Date
    let endedAt: Date
    let outcome: WalkOutcome
}

struct WalkingMeetingView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private static let waitingBrief = "No walk in progress. The calendar evasion unit is standing by."

    @AppStorage("walkingSession.draft.title") private var meetingTitle = ""
    @AppStorage("walkingSession.draft.objective") private var objective = ""
    @AppStorage("walkingSession.draft.route") private var routeContext = ""
    @AppStorage("walkingSession.draft.minutes") private var plannedMinutes = 30.0
    @AppStorage("walkingSession.draft.reminder") private var reminderEnabled = false
    @AppStorage("walkingSession.active") private var storedActive = ""
    @AppStorage("walkingSession.history") private var storedHistory = "[]"
    @AppStorage("walkingSession.brief") private var latestBrief = Self.waitingBrief

    @State private var activeMeeting: ActiveWalkingMeeting?
    @State private var history: [WalkingMeetingRecord] = []
    @State private var noteDraft = ""
    @State private var hasLoaded = false
    @State private var showAllHistory = false
    @State private var showEraseConfirmation = false
    @State private var notificationMessage = "Off. No finish-line nudge."

    private let accent = CorpPalette.bathroomBlue
    private let green = CorpPalette.parkGreen
    private let yellow = CorpPalette.sunshine

    var body: some View {
        AppCanvas(accent: accent) {
            AppHeader(
                eyebrow: "WALKING MEETING FIELD UNIT",
                title: "Take this meeting outside.",
                subtitle: "Time a real walk, keep the agenda moving, and return with an actual decision.",
                accent: accent
            )

            boundaryCard
            lifetimeSummary

            if let activeMeeting {
            activeCard(activeMeeting)
            } else {
            planningCard

            }

            fieldBrief
            historyCard

            Button { showEraseConfirmation = true } label: {
            Label("Erase complete walking archive", systemImage: "trash.fill")
            .font(.subheadline.weight(.black))
            .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(activeMeeting == nil && history.isEmpty && !hasDraft && latestBrief == Self.waitingBrief)
            .accessibilityIdentifier("eraseWalkingArchiveButton")

        } bottomBar: {
            if activeMeeting != nil {
                HStack(spacing: 10) {
                    Button {
                        finish(.completed)
                    } label: {
                        Label("Finish meeting", systemImage: "checkmark.circle.fill")
                            .font(.subheadline.weight(.black))
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .foregroundStyle(CorpPalette.actionInk)
                    .background(green, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .buttonStyle(DumbPressStyle())
                    .accessibilityIdentifier("finishWalkingMeetingButton")

                    Button {
                        finish(.endedEarly)
                    } label: {
                        Label("End early", systemImage: "xmark.circle.fill")
                            .font(.subheadline.weight(.black))
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .foregroundStyle(accent)
                    .buttonStyle(DumbPressStyle())
                    .accessibilityIdentifier("endWalkingMeetingEarlyButton")
                }
            } else {
                DumbAction(
                    title: "Start walking meeting",
                    accent: accent,
                    systemImage: "figure.walk.motion",
                    action: startMeeting
                )
                .disabled(cleanTitle.isEmpty || cleanObjective.isEmpty)
                .accessibilityIdentifier("startWalkingMeetingButton")
            }

        }
        .onAppear { restoreState(); refreshNotificationStatus() }
        .onChange(of: reminderEnabled) { _, enabled in
            if enabled { refreshNotificationStatus() }
            else { notificationMessage = "Off. No finish-line nudge." }
        }
        .confirmationDialog("Erase active walk and all meeting history?", isPresented: $showEraseConfirmation, titleVisibility: .visible) {
            Button("Confirm erase complete walking archive", role: .destructive, action: eraseAll)
            Button("Keep walking", role: .cancel) {}
        } message: {
            Text("This erases every walking session, note, and reminder. It cannot be undone.")
        }
    }

    private var boundaryCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 8) {
                DumbStatusPill("FIELD SESSION", systemImage: "map.fill", accent: accent)
                Text("Start the timer, set the objective, and prepare an exit line. You choose the route and company.")
                    .font(.subheadline.weight(.bold)).foregroundStyle(CorpPalette.ink).fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var lifetimeSummary: some View {
        DumbCard(accent: accent, isSelected: !history.isEmpty) {
            HStack(spacing: 8) {
                metric("\(history.count)", "walks")
                Divider()
                metric("\(completedCount)", "completed")
                Divider()
                metric(formatDuration(totalWalkingSeconds), "recorded")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Walking meeting history summary")
        .accessibilityValue("\(history.count) walks, \(completedCount) completed, \(formatDuration(totalWalkingSeconds)) recorded")
        .accessibilityIdentifier("walkingHistorySummary")
    }

    private func metric(_ value: String, _ label: String) -> some View {
        VStack(spacing: 3) {
            Text(value).font(.title3.weight(.black).monospacedDigit()).foregroundStyle(accent).minimumScaleFactor(0.65).lineLimit(1)
            Text(label.uppercased()).font(.caption2.weight(.black)).tracking(0.35).foregroundStyle(CorpPalette.mutedInk)
        }
        .frame(maxWidth: .infinity)
    }

    private var planningCard: some View {
        DumbCard(accent: accent, isSelected: !cleanTitle.isEmpty && !cleanObjective.isEmpty) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("FIELD PLAN").font(.caption2.weight(.black).monospaced()).tracking(1.1).foregroundStyle(CorpPalette.mutedInk)
                    Spacer()
                    Text("ESCAPE BRIEF").font(.caption2.weight(.black).monospaced()).foregroundStyle(accent)
                }
                DumbField("Meeting title", maxLength: 100, text: $meetingTitle)
                DumbField("One decision or objective", axis: .vertical, maxLength: 240, text: $objective)
                DumbField("Route or accessibility note (optional)", axis: .vertical, maxLength: 240, text: $routeContext)
                DumbSlider(title: "Planned minutes", value: $plannedMinutes, range: 10...120, step: 5, accent: accent)
                Toggle(isOn: $reminderEnabled) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Remind me at the planned end").font(.subheadline.weight(.black)).foregroundStyle(CorpPalette.ink)
                        Text("We’ll ask before turning this reminder on.").font(.caption.weight(.semibold)).foregroundStyle(CorpPalette.mutedInk)
                    }
                }
                .tint(accent)
                .accessibilityIdentifier("walkingReminderToggle")
                if reminderEnabled {
                    Text(notificationMessage)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("walkingNotificationStatus")
                }
            }
        }
        .accessibilityIdentifier("walkingMeetingPlan")
    }

    private func activeCard(_ meeting: ActiveWalkingMeeting) -> some View {
        DumbCard(accent: accent, isSelected: true) {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                let elapsed = elapsedSeconds(meeting, at: context.date)
                let remaining = max(0, meeting.plannedMinutes * 60 - elapsed)
                VStack(alignment: .leading, spacing: 15) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("WALK IN PROGRESS").font(.caption2.weight(.black).monospaced()).tracking(1.1).foregroundStyle(CorpPalette.mutedInk)
                            Text(meeting.title).font(.title3.weight(.black)).foregroundStyle(CorpPalette.ink)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(formatClock(elapsed)).font(.title2.weight(.black).monospacedDigit()).foregroundStyle(accent)
                            Text(remaining == 0 ? "PLAN ENDED" : "\(formatDuration(remaining)) left").font(.caption2.weight(.black)).foregroundStyle(remaining == 0 ? CorpPalette.warningRed : CorpPalette.mutedInk)
                        }
                    }

                    routeStrip(meeting)
                    Text(meeting.objective).font(.headline.weight(.black)).foregroundStyle(CorpPalette.ink).fixedSize(horizontal: false, vertical: true)
                    if !meeting.routeContext.isEmpty {
                        Label(meeting.routeContext, systemImage: "figure.roll").font(.caption.weight(.bold)).foregroundStyle(CorpPalette.mutedInk)
                    }
                    checkpointList(meeting)
                    noteComposer(meeting)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Active walking meeting")
        .accessibilityValue("\(meeting.completedCheckpoints.count) of 3 checkpoints, \(meeting.notes.count) notes, \(meeting.plannedMinutes) planned minutes")
        .accessibilityIdentifier("activeWalkingMeeting")
    }

    private func routeStrip(_ meeting: ActiveWalkingMeeting) -> some View {
        HStack(spacing: 4) {
            ForEach(WalkCheckpoint.allCases) { checkpoint in
                Circle().fill(meeting.completedCheckpoints.contains(checkpoint) ? green : accent.opacity(0.18)).frame(width: 16, height: 16)
                if checkpoint != .nextStep { Rectangle().fill(accent.opacity(0.25)).frame(height: 3) }
            }
            Image(systemName: "figure.walk").font(.title3.weight(.black)).foregroundStyle(yellow)
        }
        .padding(11).frame(maxWidth: .infinity)
        .background(accent.opacity(0.08), in: Capsule())
        .accessibilityHidden(true)
    }

    private func checkpointList(_ meeting: ActiveWalkingMeeting) -> some View {
        VStack(spacing: 8) {
            ForEach(WalkCheckpoint.allCases) { checkpoint in
                let completed = meeting.completedCheckpoints.contains(checkpoint)
                Button { toggle(checkpoint) } label: {
                    HStack {
                        Image(systemName: checkpoint.symbol).frame(width: 22)
                        Text(checkpoint.label).font(.subheadline.weight(.black))
                        Spacer()
                        Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                    }
                    .foregroundStyle(completed ? CorpPalette.actionInk : CorpPalette.ink)
                    .padding(.horizontal, 13).frame(minHeight: DumbMetrics.minimumTapTarget)
                    .background(completed ? green : accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(DumbPressStyle())
                .accessibilityLabel(checkpoint.label)
                .accessibilityValue(completed ? "Completed" : "Not completed")
                .accessibilityIdentifier("walkCheckpoint\(checkpoint.rawValue)")
            }
        }
    }

    private func noteComposer(_ meeting: ActiveWalkingMeeting) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            DumbField("Decision or note", maxLength: 240, text: $noteDraft)
            Button { addNote() } label: {
                Label("Add timestamped note", systemImage: "plus.circle.fill").font(.caption.weight(.black)).frame(maxWidth: .infinity, minHeight: DumbMetrics.minimumTapTarget)
            }
            .buttonStyle(.bordered).tint(accent).disabled(cleanNoteDraft.isEmpty)
            .accessibilityIdentifier("addWalkingNoteButton")
            if !meeting.notes.isEmpty {
                ForEach(meeting.notes.suffix(3)) { note in
                    Text("\(formatClock(note.secondsFromStart)) — \(note.text)").font(.caption.weight(.bold).monospaced()).foregroundStyle(CorpPalette.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private func outcomeButton(_ title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) { Text(title).font(.caption.weight(.black)).frame(maxWidth: .infinity, minHeight: DumbMetrics.minimumTapTarget) }
            .buttonStyle(.borderedProminent).tint(color)
    }

    private var fieldBrief: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("WALKING MEETING FIELD BRIEF").font(.caption.weight(.black).monospaced()).tracking(0.55)
                    Text("ROUTE \(briefNumber)").font(.caption2.weight(.bold).monospaced()).foregroundStyle(CorpPalette.mutedInk)
                }
                Spacer()
                Image(systemName: "shoeprints.fill").font(.largeTitle.weight(.black)).foregroundStyle(accent).rotationEffect(.degrees(-12)).accessibilityHidden(true)
            }
            routeDashes
            Text(latestBrief).font(.system(.subheadline, design: .monospaced).weight(.bold)).foregroundStyle(CorpPalette.ink).fixedSize(horizontal: false, vertical: true)
            HStack { Text("MEETING TIMER"); Spacer(); Text("EXIT PREPARED") }
                .font(.caption2.weight(.black).monospaced()).foregroundStyle(CorpPalette.mutedInk)
        }
        .padding(19)
        .background {
            RoundedRectangle(cornerRadius: 9, style: .continuous).fill(CorpPalette.surface)
                .shadow(color: accent.opacity(0.15), radius: 0, x: 4, y: 5)
        }
        .overlay(RoundedRectangle(cornerRadius: 9).stroke(accent, style: StrokeStyle(lineWidth: 2, dash: [3, 5])))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Walking meeting field brief")
        .accessibilityValue(latestBrief)
        .accessibilityIdentifier("walkingFieldBrief")
    }

    private var routeDashes: some View {
        HStack(spacing: 5) {
            ForEach(0..<7, id: \.self) { index in
                Circle().fill(index.isMultiple(of: 2) ? accent : yellow).frame(width: 8, height: 8)
            }
            Rectangle().fill(accent).frame(height: 2)
            Image(systemName: "flag.checkered").foregroundStyle(accent)
        }
        .accessibilityHidden(true)
    }

    private var historyCard: some View {
        DumbCard(accent: accent, isSelected: !history.isEmpty) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    DumbStatusPill("WALK LOG", systemImage: "figure.walk.circle.fill", accent: accent)
                    Spacer()
                    Text("\(history.count) \(history.count == 1 ? "walk" : "walks")")
                        .font(.caption.weight(.black)).foregroundStyle(CorpPalette.mutedInk)
                        .accessibilityIdentifier("walkingHistoryCount").accessibilityValue("\(history.count)")
                }
                if history.isEmpty {
                    Label("No completed walking meeting yet.", systemImage: "tray")
                        .font(.subheadline.weight(.bold)).foregroundStyle(CorpPalette.mutedInk)
                        .accessibilityIdentifier("emptyWalkingHistory")
                } else {
                    ForEach(Array(visibleHistory.enumerated()), id: \.element.id) { index, record in
                        if index > 0 { Divider() }
                        historyRow(record)
                    }
                    if history.count > 5 {
                        Button(showAllHistory ? "Show newest five" : "Browse all \(history.count) walks") { withAnimation(reduceMotion ? nil : .snappy) { showAllHistory.toggle() } }
                            .font(.subheadline.weight(.black)).foregroundStyle(accent)
                    }
                }
            }
        }
    }

    private func historyRow(_ record: WalkingMeetingRecord) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text(record.title).font(.headline.weight(.black)).foregroundStyle(CorpPalette.ink)
                Spacer()
                Text(record.outcome.label).font(.caption2.weight(.black)).foregroundStyle(record.outcome == .completed ? green : CorpPalette.warningRed)
            }
            Text(record.objective).font(.subheadline.weight(.bold)).foregroundStyle(CorpPalette.ink).lineLimit(3)
            Text("\(formatDuration(record.actualSeconds)) recorded · \(record.completedCheckpoints.count)/3 checkpoints · \(record.notes.count) notes")
                .font(.caption.weight(.semibold)).foregroundStyle(CorpPalette.mutedInk)
            Text(record.startedAt.formatted(date: .abbreviated, time: .shortened)).font(.caption2.weight(.bold)).foregroundStyle(CorpPalette.mutedInk)
            Button(role: .destructive) { delete(record) } label: {
                Label("Delete walking meeting", systemImage: "trash").font(.caption.weight(.black))
            }
        }
        .padding(.vertical, 3)
    }

    private var cleanTitle: String { meetingTitle.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var cleanObjective: String { objective.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var cleanRoute: String { routeContext.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var cleanNoteDraft: String { noteDraft.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var hasDraft: Bool { !cleanTitle.isEmpty || !cleanObjective.isEmpty || !cleanRoute.isEmpty || Int(plannedMinutes) != 30 || reminderEnabled }
    private var completedCount: Int { history.filter { $0.outcome == .completed }.count }
    private var totalWalkingSeconds: Int { history.reduce(0) { $0 + $1.actualSeconds } }
    private var visibleHistory: [WalkingMeetingRecord] { showAllHistory ? history : Array(history.prefix(5)) }
    private var briefNumber: String { String((activeMeeting?.id.uuidString ?? history.first?.id.uuidString ?? "000000").prefix(6)) }

    private func startMeeting() {
        guard !cleanTitle.isEmpty, !cleanObjective.isEmpty else { return }
        let meeting = ActiveWalkingMeeting(
            id: UUID(), title: cleanTitle, objective: cleanObjective, routeContext: cleanRoute,
            plannedMinutes: Int(plannedMinutes), startedAt: Date(), reminderEnabled: reminderEnabled,
            completedCheckpoints: [], notes: []
        )
        activeMeeting = meeting
        latestBrief = "WALK STARTED — \(meeting.title), \(meeting.plannedMinutes) planned minutes. Objective: \(meeting.objective)"
        persistActive()
        if meeting.reminderEnabled { scheduleEndReminder(for: meeting) }
        clearDraft(keepBrief: true)
        #if canImport(ActivityKit)
        Task { await WalkingLivePresentation.begin(meeting: meeting) }
        #endif
    }

    private func toggle(_ checkpoint: WalkCheckpoint) {
        guard var meeting = activeMeeting else { return }
        if let index = meeting.completedCheckpoints.firstIndex(of: checkpoint) { meeting.completedCheckpoints.remove(at: index) }
        else { meeting.completedCheckpoints.append(checkpoint) }
        activeMeeting = meeting
        latestBrief = "CHECKPOINT UPDATE — \(meeting.completedCheckpoints.count) of 3 agenda markers complete."
        persistActive()
    }

    private func addNote() {
        guard var meeting = activeMeeting, !cleanNoteDraft.isEmpty else { return }
        let note = WalkNote(id: UUID(), text: cleanNoteDraft, secondsFromStart: elapsedSeconds(meeting, at: Date()))
        meeting.notes.append(note); meeting.notes = Array(meeting.notes.suffix(30)); activeMeeting = meeting
        latestBrief = "FIELD NOTE ADDED at \(formatClock(note.secondsFromStart)) — \(note.text)"
        noteDraft = ""; persistActive()
    }

    private func finish(_ outcome: WalkOutcome) {
        guard let meeting = activeMeeting else { return }
        let endedAt = Date()
        let record = WalkingMeetingRecord(
            id: meeting.id, title: meeting.title, objective: meeting.objective, routeContext: meeting.routeContext,
            plannedMinutes: meeting.plannedMinutes, actualSeconds: elapsedSeconds(meeting, at: endedAt),
            completedCheckpoints: meeting.completedCheckpoints, notes: meeting.notes,
            startedAt: meeting.startedAt, endedAt: endedAt, outcome: outcome
        )
        DumbLocalNotifications.cancel(identifier: reminderIdentifier(meeting))
        history.insert(record, at: 0); history = Array(history.prefix(40)); activeMeeting = nil; noteDraft = ""
        latestBrief = outcome == .completed
            ? "WALK COMPLETE — \(record.title): \(record.completedCheckpoints.count)/3 checkpoints and \(record.notes.count) field notes."
            : "WALK ENDED EARLY — \(record.title) after \(formatDuration(record.actualSeconds)). Progress was preserved without pretending it finished."
        persistActive(); persistHistory()
        #if canImport(ActivityKit)
        Task { await WalkingLivePresentation.finish(sessionID: meeting.id) }
        #endif
    }

    private func delete(_ record: WalkingMeetingRecord) {
        history.removeAll { $0.id == record.id }; latestBrief = history.isEmpty ? Self.waitingBrief : "One completed walk was removed from the log."; persistHistory()
    }
    private func clearDraft(keepBrief: Bool = false) {
        meetingTitle = ""; objective = ""; routeContext = ""; plannedMinutes = 30; reminderEnabled = false
        if !keepBrief { latestBrief = Self.waitingBrief }
    }
    private func eraseAll() {
        if let activeMeeting { DumbLocalNotifications.cancel(identifier: reminderIdentifier(activeMeeting)) }
        activeMeeting = nil; history = []; noteDraft = ""; showAllHistory = false; clearDraft(); persistActive(); persistHistory()
    }

    private func elapsedSeconds(_ meeting: ActiveWalkingMeeting, at date: Date) -> Int { max(0, Int(date.timeIntervalSince(meeting.startedAt))) }
    private func formatClock(_ seconds: Int) -> String { String(format: "%02d:%02d", seconds / 60, seconds % 60) }
    private func formatDuration(_ seconds: Int) -> String {
        if seconds < 60 { return "\(seconds)s" }
        let minutes = seconds / 60
        return minutes < 60 ? "\(minutes)m" : "\(minutes / 60)h \(minutes % 60)m"
    }

    private func reminderIdentifier(_ meeting: ActiveWalkingMeeting) -> String { "walking-end-\(meeting.id.uuidString)" }
    private func scheduleEndReminder(for meeting: ActiveWalkingMeeting) {
        Task {
            let result = await DumbLocalNotifications.scheduleOneShot(
                identifier: reminderIdentifier(meeting), title: "Walking meeting checkpoint",
                body: "Your planned meeting window has ended. Capture the decision or end the session.",
                proposedDate: meeting.startedAt.addingTimeInterval(Double(meeting.plannedMinutes * 60))
            )
            await MainActor.run {
                switch result {
                case .scheduled(let date): notificationMessage = "Planned-end checkpoint scheduled for \(date.formatted(date: .omitted, time: .shortened))."
                case .denied: notificationMessage = "Reminder not scheduled. Notifications are disabled in Settings."
                case .failed: notificationMessage = "The planned-end reminder could not be scheduled. The live timer still works."
                }
            }
        }
    }
    private func refreshNotificationStatus() {
        guard reminderEnabled else { return }
        Task {
            let status = await DumbLocalNotifications.authorization()
            await MainActor.run {
                switch status {
                case .available: notificationMessage = "Notifications are available. Starting schedules one planned-end checkpoint."
                case .notDetermined: notificationMessage = "We’ll ask before turning this reminder on."
                case .denied: notificationMessage = "Notifications are disabled in Settings; walking sessions still work."
                }
            }
        }
    }

    private func restoreState() {
        guard !hasLoaded else { return }; hasLoaded = true
        if let data = storedActive.data(using: .utf8), let decoded = try? JSONDecoder().decode(ActiveWalkingMeeting.self, from: data) { activeMeeting = decoded }
        if let data = storedHistory.data(using: .utf8), let decoded = try? JSONDecoder().decode([WalkingMeetingRecord].self, from: data) { history = decoded }
    }
    private func persistActive() {
        guard let activeMeeting else { storedActive = ""; return }
        guard let data = try? JSONEncoder().encode(activeMeeting), let encoded = String(data: data, encoding: .utf8) else { return }
        storedActive = encoded
    }
    private func persistHistory() {
        guard let data = try? JSONEncoder().encode(history), let encoded = String(data: data, encoding: .utf8) else { return }
        storedHistory = encoded
    }
}

#if canImport(ActivityKit)
private enum WalkingLivePresentation {
    static func begin(meeting: ActiveWalkingMeeting) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attributes = WalkingMeetingActivityAttributes(meetingTitle: meeting.title, sessionID: meeting.id)
        let state = WalkingMeetingActivityAttributes.ContentState(elapsedMinutes: 0, status: meeting.objective)
        _ = try? Activity.request(
            attributes: attributes,
            content: ActivityContent(state: state, staleDate: nil),
            pushType: nil
        )
    }

    static func finish(sessionID: UUID) async {
        for activity in Activity<WalkingMeetingActivityAttributes>.activities where activity.attributes.sessionID == sessionID {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
}
#endif

#if canImport(PreviewsMacros)
#Preview { WalkingMeetingView() }
#endif
