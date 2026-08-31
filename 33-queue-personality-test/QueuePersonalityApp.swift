import SwiftUI
import DumbKit
#if canImport(ActivityKit)
import ActivityKit
#endif

@main
struct QueuePersonalityApp: App {
    var body: some Scene { WindowGroup { QueuePersonalityView().dumbNativeEntry(scheme: "app33queuepersonality") { _, _ in } } }
}

private struct ActiveQueue: Codable, Identifiable {
    let id: UUID
    let name: String
    let startedAt: Date
    let initialPeopleAhead: Int
    var peopleAhead: Int
    var peopleServed: Int
    let fallbackMinutesPerPerson: Int
    let remindersEnabled: Bool
    var lastUpdatedAt: Date
}

private enum QueueOutcome: String, Codable {
    case reachedFront
    case leftQueue

    var label: String { self == .reachedFront ? "REACHED FRONT" : "LEFT QUEUE" }
}

private struct QueueRecord: Codable, Identifiable {
    let id: UUID
    let name: String
    let startedAt: Date
    let endedAt: Date
    let initialPeopleAhead: Int
    let peopleServed: Int
    let secondsWaited: Int
    let outcome: QueueOutcome
}

struct QueuePersonalityView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private static let waitingTicket = "No active line. Start a real queue session to open the observation booth."

    @AppStorage("queueTracker.draft.name") private var queueName = ""
    @AppStorage("queueTracker.draft.peopleAhead") private var peopleAhead = 5.0
    @AppStorage("queueTracker.draft.minutesPerPerson") private var minutesPerPerson = 3.0
    @AppStorage("queueTracker.draft.reminders") private var remindersEnabled = false
    @AppStorage("queueTracker.active") private var storedActive = ""
    @AppStorage("queueTracker.history") private var storedHistory = "[]"
    @AppStorage("queueTracker.ticket") private var latestTicket = Self.waitingTicket

    @State private var activeQueue: ActiveQueue?
    @State private var history: [QueueRecord] = []
    @State private var hasLoaded = false
    @State private var showAllHistory = false
    @State private var showEraseConfirmation = false
    @State private var notificationMessage = "Off. No turn-time nudge."

    private let accent = CorpPalette.violet
    private let mint = CorpPalette.evidenceMint

    var body: some View {
        AppCanvas(accent: accent) {
            AppHeader(
                eyebrow: "QUEUE OBSERVATORY",
                title: "Queue wait tracker",
                subtitle: "Time a real line, log what moves, and collect an official queue archetype.",
                accent: accent
            )

            DumbBoundaryChip(
                storageKey: "queuePersonality.boundaryDismissed",
                message: "Personal queue journal — not live wait-time data or venue integrations.",
                accent: accent,
                systemImage: "figure.wave"
            )

            formulaCard
            lifetimeSummary

            if let activeQueue {
            activeCard(activeQueue)
            } else {
            startCard

            }

            queueTicket

            if latestTicket != Self.waitingTicket {
                DumbShareVerdict(
                    text: latestTicket,
                    subject: "Queue personality ticket",
                    accent: accent,
                    accessibilityIdentifier: "shareQueueTicketButton"
                )
            }

            historyCard

            Button { showEraseConfirmation = true } label: {
            Label("Erase complete queue archive", systemImage: "trash.fill")
            .font(.subheadline.weight(.black))
            .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(CorpPalette.warningRed)
            .buttonStyle(DumbPressStyle())
            .disabled(activeQueue == nil && history.isEmpty && !hasDraft && latestTicket == Self.waitingTicket)
            .accessibilityIdentifier("eraseQueueArchiveButton")

        } bottomBar: {
            if let activeQueue {
                VStack(spacing: DumbSpacing.sm) {
                    DumbAction(
                        title: "Person served",
                        accent: accent,
                        systemImage: "person.fill.checkmark",
                        action: personServed
                    )
                    .disabled(activeQueue.peopleAhead == 0)
                    .accessibilityIdentifier("queuePersonServedButton")

                    HStack(spacing: 10) {
                        Button { finish(.reachedFront) } label: {
                            Label("Reached front", systemImage: "figure.wave")
                                .font(.subheadline.weight(.black))
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .foregroundStyle(CorpPalette.actionInk)
                        .background(CorpPalette.parkGreen, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .buttonStyle(DumbPressStyle())
                        .accessibilityIdentifier("queueReachedFrontButton")

                        Button { finish(.leftQueue) } label: {
                            Label("Left queue", systemImage: "figure.walk.departure")
                                .font(.subheadline.weight(.black))
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .foregroundStyle(accent)
                        .buttonStyle(DumbPressStyle())
                        .accessibilityIdentifier("queueLeftQueueButton")
                    }
                }
            } else {
                DumbAction(
                    title: "Start queue session",
                    accent: accent,
                    systemImage: "person.3.sequence.fill",
                    action: startQueue
                )
                .disabled(cleanQueueName.isEmpty)
                .accessibilityIdentifier("startQueueSessionButton")
            }

        }
        .onAppear { restoreState(); refreshNotificationStatus() }
        .onChange(of: remindersEnabled) { _, enabled in if enabled { refreshNotificationStatus() } }
        .confirmationDialog("Erase active wait and all queue history?", isPresented: $showEraseConfirmation, titleVisibility: .visible) {
            Button("Confirm erase complete queue archive", role: .destructive, action: eraseAll)
            Button("Keep waiting", role: .cancel) {}
        } message: {
            Text("This erases every queue session and reminder. It cannot be undone.")
        }
    }

    private var formulaCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 8) {
                DumbStatusPill("PUBLISHED ESTIMATE", systemImage: "function", accent: accent)
                Text("Before anyone is served: people ahead × your starting minutes per person. After the line moves, the estimate learns from the pace you observed. It’s an estimate, not a reservation or guarantee.")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CorpPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var lifetimeSummary: some View {
        DumbCard(accent: accent, isSelected: !history.isEmpty) {
            HStack(spacing: 8) {
                metric("\(history.count)", "finished")
                Divider()
                metric(formatDuration(averageWaitSeconds), "average")
                Divider()
                metric(formatDuration(longestWaitSeconds), "longest")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Queue history summary")
        .accessibilityValue("\(history.count) finished sessions, average \(formatDuration(averageWaitSeconds)), longest \(formatDuration(longestWaitSeconds))")
        .accessibilityIdentifier("queueHistorySummary")
    }

    private func metric(_ value: String, _ label: String) -> some View {
        VStack(spacing: 3) {
            Text(value).font(.title3.weight(.black).monospacedDigit()).foregroundStyle(accent).minimumScaleFactor(0.7).lineLimit(1)
            Text(label.uppercased()).font(.caption2.weight(.black)).tracking(0.4).foregroundStyle(CorpPalette.mutedInk)
        }
        .frame(maxWidth: .infinity)
    }

    private var startCard: some View {
        DumbCard(accent: accent, isSelected: !cleanQueueName.isEmpty) {
            VStack(alignment: .leading, spacing: 14) {
                Text("OPEN A REAL LINE").font(.caption2.weight(.black).monospaced()).tracking(1.2).foregroundStyle(CorpPalette.mutedInk)
                DumbField("Queue name or place", maxLength: 100, text: $queueName)
                DumbSlider(title: "People ahead of you", value: $peopleAhead, range: 0...50, step: 1, accent: accent)
                DumbSlider(title: "Starting minutes per person", value: $minutesPerPerson, range: 1...20, step: 1, accent: CorpPalette.sunshine)
                Text("Starting estimate: \(formatDuration(Int(peopleAhead) * Int(minutesPerPerson) * 60)).")
                    .font(.caption.weight(.black)).foregroundStyle(accent)
                    .accessibilityIdentifier("queueStartingEstimate")
                Toggle(isOn: $remindersEnabled) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Remind me near the estimated front")
                            .font(.subheadline.weight(.black)).foregroundStyle(CorpPalette.ink)
                        Text("We’ll ask before turning this reminder on.")
                            .font(.caption.weight(.semibold)).foregroundStyle(CorpPalette.mutedInk)
                    }
                }
                .tint(accent)
                .accessibilityIdentifier("queueReminderToggle")
                if remindersEnabled {
                    Text(notificationMessage)
                        .font(.caption.weight(.bold)).foregroundStyle(CorpPalette.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("queueNotificationStatus")
                }
            }
        }
    }

    private func activeCard(_ queue: ActiveQueue) -> some View {
        DumbCard(accent: accent, isSelected: true) {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                let elapsed = elapsedSeconds(queue, at: context.date)
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("ACTIVE QUEUE").font(.caption2.weight(.black).monospaced()).tracking(1.1).foregroundStyle(CorpPalette.mutedInk)
                            Text(queue.name).font(.title3.weight(.black)).foregroundStyle(CorpPalette.ink)
                        }
                        Spacer()
                        Text(formatClock(elapsed)).font(.title2.weight(.black).monospacedDigit()).foregroundStyle(accent)
                    }

                    DumbStatusPill(
                        liveArchetype(for: queue, elapsed: elapsed),
                        systemImage: "person.fill.questionmark",
                        accent: accent
                    )
                    .accessibilityIdentifier("liveQueueArchetype")

                    HStack(spacing: 8) {
                        activeMetric("\(queue.peopleAhead)", "ahead")
                        Divider()
                        activeMetric("\(queue.peopleServed)", "served")
                        Divider()
                        activeMetric(etaText(queue, elapsed: elapsed), "ETA")
                    }
                    .frame(height: 58)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Active queue progress")
                    .accessibilityValue("\(queue.peopleAhead) people ahead, \(queue.peopleServed) served, estimated \(etaText(queue, elapsed: elapsed))")
                    .accessibilityIdentifier("activeQueueProgress")

                    positionTrail(queue)

                    activeButton("Joined ahead", image: "person.badge.plus") { personJoinedAhead() }
                    if queue.peopleAhead > 0 {
                        activeButton("Correct: one fewer ahead", image: "minus.circle.fill") { correctOneFewer() }
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Active queue")
        .accessibilityValue("\(queue.peopleAhead) people ahead, \(queue.peopleServed) served")
        .accessibilityIdentifier("activeQueueCard")
    }

    private func activeMetric(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.headline.weight(.black).monospacedDigit()).foregroundStyle(accent).minimumScaleFactor(0.65).lineLimit(1)
            Text(label.uppercased()).font(.caption2.weight(.black)).foregroundStyle(CorpPalette.mutedInk)
        }.frame(maxWidth: .infinity)
    }

    private func positionTrail(_ queue: ActiveQueue) -> some View {
        let shown = min(max(queue.initialPeopleAhead, queue.peopleAhead), 12)
        return HStack(spacing: 5) {
            ForEach(0..<shown, id: \.self) { index in
                Circle()
                    .fill(index < queue.peopleAhead ? accent : mint)
                    .frame(width: 13, height: 13)
            }
            Image(systemName: "person.crop.circle.fill").font(.title3).foregroundStyle(CorpPalette.sunshine)
        }
        .padding(10).frame(maxWidth: .infinity)
        .background(accent.opacity(0.1), in: Capsule())
        .accessibilityHidden(true)
    }

    private func activeButton(_ title: String, image: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: image).font(.caption.weight(.black)).frame(maxWidth: .infinity, minHeight: DumbMetrics.minimumTapTarget)
        }.buttonStyle(.bordered).tint(accent)
    }

    private func outcomeButton(_ title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) { Text(title).font(.caption.weight(.black)).frame(maxWidth: .infinity, minHeight: DumbMetrics.minimumTapTarget) }
            .buttonStyle(.borderedProminent).tint(color)
    }

    private var queueTicket: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("QUEUE OBSERVATION TICKET").font(.caption.weight(.black).monospaced()).tracking(0.7)
                    Text("NUMBER \(ticketNumber)").font(.caption2.weight(.bold).monospaced()).foregroundStyle(CorpPalette.mutedInk)
                }
                Spacer()
                Image(systemName: "ticket.fill").font(.largeTitle.weight(.black)).foregroundStyle(accent).rotationEffect(.degrees(-8)).accessibilityHidden(true)
            }
            Rectangle().fill(accent).frame(height: 3)
            Text(latestTicket).font(.system(.subheadline, design: .monospaced).weight(.bold)).foregroundStyle(CorpPalette.ink).fixedSize(horizontal: false, vertical: true)
            HStack { Text("QUEUE TIMER"); Spacer(); Text("YOUR OBSERVATIONS") }
                .font(.caption2.weight(.black).monospaced()).foregroundStyle(CorpPalette.mutedInk)
        }
        .padding(19)
        .background(CorpPalette.surface, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 9).stroke(accent, style: StrokeStyle(lineWidth: 2, dash: [3, 3])))
        .shadow(color: accent.opacity(0.16), radius: 0, x: 4, y: 5)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Queue observation ticket")
        .accessibilityValue(latestTicket)
        .accessibilityIdentifier("queueObservationTicket")
    }

    private var historyCard: some View {
        DumbCard(accent: accent, isSelected: !history.isEmpty) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    DumbStatusPill("WAIT LOG", systemImage: "clock.arrow.circlepath", accent: accent)
                    Spacer()
                    Text("\(history.count) \(history.count == 1 ? "session" : "sessions")")
                        .font(.caption.weight(.black)).foregroundStyle(CorpPalette.mutedInk)
                        .accessibilityIdentifier("queueHistoryCount").accessibilityValue("\(history.count)")
                }
                if history.isEmpty {
                    DumbEmptyInvite(
                        title: "No completed queue session yet",
                        message: "Start a queue session and finish it to collect your personality ticket.",
                        systemImage: "tray",
                        accent: accent
                    )
                    .accessibilityIdentifier("emptyQueueHistory")
                } else {
                    ForEach(Array(visibleHistory.enumerated()), id: \.element.id) { index, record in
                        if index > 0 { Divider() }
                        historyRow(record)
                    }
                    if history.count > 5 {
                        Button(showAllHistory ? "Show newest five" : "Browse all \(history.count) sessions") { withAnimation(reduceMotion ? nil : .snappy) { showAllHistory.toggle() } }
                            .font(.subheadline.weight(.black)).foregroundStyle(accent)
                    }
                }
            }
        }
    }

    private func historyRow(_ record: QueueRecord) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(record.name).font(.headline.weight(.black)).foregroundStyle(CorpPalette.ink)
                Spacer()
                Text(record.outcome.label).font(.caption2.weight(.black)).foregroundStyle(record.outcome == .reachedFront ? CorpPalette.parkGreen : CorpPalette.warningRed)
            }
            Text("Waited \(formatDuration(record.secondsWaited)) · \(record.peopleServed) observed served · started with \(record.initialPeopleAhead) ahead")
                .font(.caption.weight(.semibold)).foregroundStyle(CorpPalette.mutedInk)
            Text(record.startedAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2.weight(.bold)).foregroundStyle(CorpPalette.mutedInk)
            Button(role: .destructive) { delete(record) } label: {
                Label("Delete queue session", systemImage: "trash").font(.caption.weight(.black))
            }
        }.padding(.vertical, 3)
    }

    private var cleanQueueName: String { queueName.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var hasDraft: Bool { !cleanQueueName.isEmpty || Int(peopleAhead) != 5 || Int(minutesPerPerson) != 3 || remindersEnabled }
    private var averageWaitSeconds: Int { history.isEmpty ? 0 : history.reduce(0) { $0 + $1.secondsWaited } / history.count }
    private var longestWaitSeconds: Int { history.map(\.secondsWaited).max() ?? 0 }
    private var visibleHistory: [QueueRecord] { showAllHistory ? history : Array(history.prefix(5)) }
    private var ticketNumber: String { String((activeQueue?.id.uuidString ?? history.first?.id.uuidString ?? "000000").prefix(6)) }

    private func startQueue() {
        guard !cleanQueueName.isEmpty else { return }
        let queue = ActiveQueue(
            id: UUID(), name: cleanQueueName, startedAt: Date(), initialPeopleAhead: Int(peopleAhead),
            peopleAhead: Int(peopleAhead), peopleServed: 0, fallbackMinutesPerPerson: Int(minutesPerPerson),
            remindersEnabled: remindersEnabled, lastUpdatedAt: Date()
        )
        activeQueue = queue
        latestTicket = "SESSION OPEN — \(queue.name): \(queue.peopleAhead) ahead. Initial estimate \(formatDuration(queue.peopleAhead * queue.fallbackMinutesPerPerson * 60)), using your starting pace."
        persistActive()
        if queue.remindersEnabled { scheduleTurnReminder(for: queue) }
        clearDraft(keepTicket: true)
        #if canImport(ActivityKit)
        Task { await QueueLivePresentation.begin(queue: queue) }
        #endif
    }

    private func personServed() {
        guard var queue = activeQueue, queue.peopleAhead > 0 else { return }
        queue.peopleAhead -= 1; queue.peopleServed += 1; queue.lastUpdatedAt = Date(); activeQueue = queue
        latestTicket = queue.peopleAhead == 0
            ? "YOU APPEAR TO BE NEXT — confirm when you reach the front."
            : "PROGRESS — \(queue.peopleServed) observed served; \(queue.peopleAhead) remain ahead. ETA now uses observed pace."
        persistActive(); rescheduleIfNeeded(queue)
        #if canImport(ActivityKit)
        if let queue = activeQueue { Task { await QueueLivePresentation.update(queue: queue) } }
        #endif
    }

    private func personJoinedAhead() {
        guard var queue = activeQueue else { return }
        queue.peopleAhead = min(99, queue.peopleAhead + 1); queue.lastUpdatedAt = Date(); activeQueue = queue
        latestTicket = "QUEUE UPDATE — one person joined ahead by your report; \(queue.peopleAhead) now remain."
        persistActive(); rescheduleIfNeeded(queue)
        #if canImport(ActivityKit)
        if let queue = activeQueue { Task { await QueueLivePresentation.update(queue: queue) } }
        #endif
    }

    private func correctOneFewer() {
        guard var queue = activeQueue, queue.peopleAhead > 0 else { return }
        queue.peopleAhead -= 1; queue.lastUpdatedAt = Date(); activeQueue = queue
        latestTicket = "POSITION CORRECTED — \(queue.peopleAhead) now remain ahead. This correction does not count as observed service."
        persistActive(); rescheduleIfNeeded(queue)
        #if canImport(ActivityKit)
        if let queue = activeQueue { Task { await QueueLivePresentation.update(queue: queue) } }
        #endif
    }

    private func finish(_ outcome: QueueOutcome) {
        guard let queue = activeQueue else { return }
        let ended = Date()
        let record = QueueRecord(
            id: queue.id, name: queue.name, startedAt: queue.startedAt, endedAt: ended,
            initialPeopleAhead: queue.initialPeopleAhead, peopleServed: queue.peopleServed,
            secondsWaited: elapsedSeconds(queue, at: ended), outcome: outcome
        )
        DumbLocalNotifications.cancel(identifier: notificationIdentifier(queue))
        history.insert(record, at: 0); history = Array(history.prefix(50)); activeQueue = nil
        latestTicket = outcome == .reachedFront
            ? "SESSION COMPLETE — \(record.name), \(formatDuration(record.secondsWaited)). Archetype: The Evidence-Based Optimist."
            : "SESSION ENDED — left \(record.name) after \(formatDuration(record.secondsWaited)). Archetype: The Boundary Setter."
        persistActive(); persistHistory()
        #if canImport(ActivityKit)
        Task { await QueueLivePresentation.finish(sessionID: queue.id) }
        #endif
    }

    private func delete(_ record: QueueRecord) {
        history.removeAll { $0.id == record.id }; latestTicket = history.isEmpty ? Self.waitingTicket : "One completed wait was removed from the log."; persistHistory()
    }

    private func clearDraft(keepTicket: Bool = false) {
        queueName = ""; peopleAhead = 5; minutesPerPerson = 3; remindersEnabled = false
        notificationMessage = "Off. No turn-time nudge."
        if !keepTicket { latestTicket = Self.waitingTicket }
    }

    private func eraseAll() {
        if let activeQueue { DumbLocalNotifications.cancel(identifier: notificationIdentifier(activeQueue)) }
        activeQueue = nil; history = []; showAllHistory = false; clearDraft(); persistActive(); persistHistory()
    }

    private func elapsedSeconds(_ queue: ActiveQueue, at date: Date) -> Int { max(0, Int(date.timeIntervalSince(queue.startedAt))) }

    private func liveArchetype(for queue: ActiveQueue, elapsed: Int) -> String {
        if queue.peopleAhead == 0 { return "THE FRONT-ROW REALIST" }
        if queue.peopleAhead > queue.initialPeopleAhead { return "THE DEFENSIVE PESSIMIST" }
        if queue.peopleServed >= 3 { return "THE PACE ANALYST" }
        if queue.peopleServed > 0 { return "THE EVIDENCE-BASED OPTIMIST" }
        if elapsed > 300 { return "THE STOIC WAITER" }
        return "THE LINE ANTHROPOLOGIST"
    }

    private func etaSeconds(_ queue: ActiveQueue, elapsed: Int) -> Int {
        guard queue.peopleAhead > 0 else { return 0 }
        if queue.peopleServed > 0 { return Int((Double(elapsed) / Double(queue.peopleServed) * Double(queue.peopleAhead)).rounded()) }
        return queue.peopleAhead * queue.fallbackMinutesPerPerson * 60
    }
    private func etaText(_ queue: ActiveQueue, elapsed: Int) -> String { queue.peopleAhead == 0 ? "your turn" : formatDuration(etaSeconds(queue, elapsed: elapsed)) }
    private func formatClock(_ seconds: Int) -> String { String(format: "%02d:%02d", seconds / 60, seconds % 60) }
    private func formatDuration(_ seconds: Int) -> String {
        if seconds < 60 { return "\(seconds)s" }
        let minutes = seconds / 60
        return minutes < 60 ? "\(minutes)m" : "\(minutes / 60)h \(minutes % 60)m"
    }

    private func notificationIdentifier(_ queue: ActiveQueue) -> String { "queue-turn-\(queue.id.uuidString)" }
    private func rescheduleIfNeeded(_ queue: ActiveQueue) {
        DumbLocalNotifications.cancel(identifier: notificationIdentifier(queue))
        if queue.remindersEnabled && queue.peopleAhead > 0 { scheduleTurnReminder(for: queue) }
    }
    private func scheduleTurnReminder(for queue: ActiveQueue) {
        let elapsed = elapsedSeconds(queue, at: Date())
        let estimate = max(60, etaSeconds(queue, elapsed: elapsed))
        Task {
            let result = await DumbLocalNotifications.scheduleOneShot(
                identifier: notificationIdentifier(queue), title: "Queue checkpoint",
                body: "Your queue estimate says the front may be approaching.",
                proposedDate: Date().addingTimeInterval(Double(estimate))
            )
            await MainActor.run {
                switch result {
                case .scheduled(let date): notificationMessage = "Estimated-turn check scheduled for \(date.formatted(date: .omitted, time: .shortened))."
                case .denied: notificationMessage = "Reminder not scheduled. Notifications are disabled in Settings."
                case .failed: notificationMessage = "The estimated-turn reminder could not be scheduled. Tracking still works."
                }
            }
        }
    }

    private func refreshNotificationStatus() {
        guard remindersEnabled else { return }
        Task {
            let status = await DumbLocalNotifications.authorization()
            await MainActor.run {
                switch status {
                case .available: notificationMessage = "Notifications are available. Starting schedules one estimated-turn checkpoint."
                case .notDetermined: notificationMessage = "We’ll ask before turning this reminder on."
                case .denied: notificationMessage = "Notifications are disabled in Settings; queue tracking still works."
                }
            }
        }
    }

    private func restoreState() {
        guard !hasLoaded else { return }; hasLoaded = true
        if let data = storedActive.data(using: .utf8), let decoded = try? JSONDecoder().decode(ActiveQueue.self, from: data) { activeQueue = decoded }
        if let data = storedHistory.data(using: .utf8), let decoded = try? JSONDecoder().decode([QueueRecord].self, from: data) { history = decoded }
    }
    private func persistActive() {
        guard let activeQueue else { storedActive = ""; return }
        guard let data = try? JSONEncoder().encode(activeQueue), let encoded = String(data: data, encoding: .utf8) else { return }
        storedActive = encoded
    }
    private func persistHistory() {
        guard let data = try? JSONEncoder().encode(history), let encoded = String(data: data, encoding: .utf8) else { return }
        storedHistory = encoded
    }
}

#if canImport(ActivityKit)
private enum QueueLivePresentation {
    static func begin(queue: ActiveQueue) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attributes = QueueActivityAttributes(queueName: queue.name, sessionID: queue.id)
        let state = QueueActivityAttributes.ContentState(
            peopleAhead: queue.peopleAhead,
            status: "Waiting in \(queue.name)"
        )
        let content = ActivityContent(state: state, staleDate: nil)
        _ = try? Activity.request(attributes: attributes, content: content, pushType: nil)
    }

    static func update(queue: ActiveQueue) async {
        let state = QueueActivityAttributes.ContentState(
            peopleAhead: queue.peopleAhead,
            status: queue.peopleAhead == 0 ? "Your turn" : "\(queue.peopleServed) served so far"
        )
        for activity in Activity<QueueActivityAttributes>.activities where activity.attributes.sessionID == queue.id {
            await activity.update(ActivityContent(state: state, staleDate: nil))
        }
    }

    static func finish(sessionID: UUID) async {
        for activity in Activity<QueueActivityAttributes>.activities where activity.attributes.sessionID == sessionID {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
}
#endif

#if canImport(PreviewsMacros)
#Preview { QueuePersonalityView() }
#endif
