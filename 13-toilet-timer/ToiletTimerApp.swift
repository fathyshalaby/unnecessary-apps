import ActivityKit
import DumbKit
import Foundation
import SwiftUI
import UserNotifications

private struct BathroomSession: Codable, Identifiable {
    let id: UUID
    let seconds: TimeInterval
    let mode: String
    let date: Date

    init(seconds: TimeInterval, mode: String, date: Date = Date()) {
        id = UUID()
        self.seconds = seconds
        self.mode = mode
        self.date = date
    }
}

private enum BathroomTimerPresentation {
    static let milestones = [5, 10, 15, 20]
    private static let notificationPrefix = "toiletTimer.milestone"

    static var isDisabledForTesting: Bool {
        ProcessInfo.processInfo.arguments.contains("-toiletTimer.disableExternalPresentation")
    }

    static func begin(startedAt: Date, sessionID: UUID) async {
        guard !isDisabledForTesting else { return }
        await scheduleMilestones(startedAt: startedAt, sessionID: sessionID)
        await startLiveActivity(startedAt: startedAt, sessionID: sessionID)
    }

    static func restore(startedAt: Date, sessionID: UUID) async {
        guard !isDisabledForTesting else { return }
        let alreadyVisible = Activity<BathroomTimerAttributes>.activities.contains {
            $0.attributes.sessionID == sessionID
        }
        if !alreadyVisible {
            await startLiveActivity(startedAt: startedAt, sessionID: sessionID)
        }
    }

    static func finish(sessionID: UUID?) async {
        guard !isDisabledForTesting else { return }
        await cancelMilestones(sessionID: sessionID)
        let activities = Activity<BathroomTimerAttributes>.activities.filter {
            sessionID == nil || $0.attributes.sessionID == sessionID
        }
        for activity in activities {
            let finalContent = ActivityContent(
                state: BathroomTimerAttributes.ContentState(status: "Session filed"),
                staleDate: nil
            )
            await activity.end(finalContent, dismissalPolicy: .after(Date().addingTimeInterval(45)))
        }
    }

    private static func startLiveActivity(startedAt: Date, sessionID: UUID) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attributes = BathroomTimerAttributes(startedAt: startedAt, sessionID: sessionID)
        let content = ActivityContent(
            state: BathroomTimerAttributes.ContentState(status: "Stall session live"),
            staleDate: nil
        )
        _ = try? Activity.request(attributes: attributes, content: content, pushType: nil)
    }

    private static func scheduleMilestones(startedAt: Date, sessionID: UUID) async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        let isAuthorized: Bool
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            isAuthorized = true
        case .notDetermined:
            isAuthorized = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        case .denied:
            isAuthorized = false
        @unknown default:
            isAuthorized = false
        }
        guard isAuthorized else { return }

        await cancelMilestones(sessionID: nil)
        for minutes in milestones {
            let fireDate = startedAt.addingTimeInterval(TimeInterval(minutes * 60))
            let interval = fireDate.timeIntervalSinceNow
            guard interval > 1 else { continue }

            let content = UNMutableNotificationContent()
            content.title = "Bathroom milestone: \(minutes) minutes"
            content.body = milestoneCopy(minutes)
            content.sound = .default
            content.threadIdentifier = "bathroom-ops"
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            let request = UNNotificationRequest(
                identifier: notificationID(sessionID: sessionID, minutes: minutes),
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }

    private static func cancelMilestones(sessionID: UUID?) async {
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
        let identifiers = pending.map(\.identifier).filter { identifier in
            guard identifier.hasPrefix(notificationPrefix) else { return false }
            guard let sessionID else { return true }
            return identifier.hasPrefix("\(notificationPrefix).\(sessionID.uuidString)")
        }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    private static func notificationID(sessionID: UUID, minutes: Int) -> String {
        "\(notificationPrefix).\(sessionID.uuidString).\(minutes)"
    }

    private static func milestoneCopy(_ minutes: Int) -> String {
        switch minutes {
        case 5: "Five minutes. A respectable opening statement."
        case 10: "Ten minutes. The grout has started taking notes."
        case 15: "Fifteen minutes. Wrap up your closing argument."
        default: "Twenty minutes. You are now a bathroom resident."
        }
    }
}

@main
struct ToiletTimerApp: App {
    var body: some Scene { WindowGroup { ToiletTimerView() } }
}

struct ToiletTimerView: View {
    private static let emptyResult = "The bathroom has not yet filed a complaint."

    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("toiletTimer.minutes") private var minutes = 8.0
    @AppStorage("toiletTimer.result") private var result = Self.emptyResult
    @AppStorage("toiletTimer.sessions") private var storedSessions = "[]"
    @AppStorage("toiletTimer.activeStartedAt") private var storedActiveStartedAt = 0.0
    @AppStorage("toiletTimer.isRunning") private var storedIsRunning = false
    @AppStorage("toiletTimer.sessionID") private var storedSessionID = ""

    @State private var activeStartedAt: Date?
    @State private var recordedSeconds: TimeInterval = 0
    @State private var isRunning = false
    @State private var sessionID: UUID?
    @State private var sessions: [BathroomSession] = []
    @State private var hasLoaded = false
    @State private var showArchiveConfirmation = false

    private let accent = CorpPalette.warningRed

    var body: some View {
        AppCanvas(accent: accent, experience: .timer) {
            AppHeader(
                eyebrow: "BATHROOM OPERATIONS",
                title: "Toilet timer",
                subtitle: "How long is too long? Now bureaucratically quantified.",
                accent: accent
            )

            heroTimerDial
            boundaryCard

            if !isRunning {
                manualEstimateCard
            }

            DumbResult(
                text: result,
                accent: accent,
                systemImage: "exclamationmark.triangle.fill",
                reactionStyle: .shake
            )
            .accessibilityIdentifier("toiletTimerResult")

            Button(action: resetCurrentSession) {
                Label("Dismiss current complaint", systemImage: "arrow.counterclockwise")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(!hasCurrentSession)
            .accessibilityIdentifier("resetBathroomButton")
            .accessibilityHint("Stops and clears the current timer without deleting saved session history.")

            sessionHistoryCard

            Button {
                showArchiveConfirmation = true
            } label: {
                Label("Erase session history", systemImage: "trash.fill")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(sessions.isEmpty)
            .accessibilityIdentifier("clearToiletHistoryButton")

            DumbNativeTip(
                "Siri & Lock Screen",
                detail: "Say “Start stall timer,” use Shortcuts, or watch the session on your Lock Screen and Dynamic Island.",
                systemImage: "timer",
                accent: accent
            )
        } bottomBar: {
            DumbAction(
                title: isRunning ? "Stop & assess the situation" : "Start stall timer",
                accent: accent,
                systemImage: isRunning ? "stopwatch.fill" : "timer",
                action: toggleTimer
            )
            .accessibilityIdentifier("assessBathroomButton")
        }
        .dumbNativeEntry(scheme: "app13toilettimer") { action, _ in
            if action == "start", !isRunning {
                beginLiveSession()
            }
        }
        .onAppear(perform: restoreState)
        .onChange(of: scenePhase) { _, _ in
            persistRunningState()
        }
        .confirmationDialog(
            "Erase every saved bathroom session?",
            isPresented: $showArchiveConfirmation,
            titleVisibility: .visible
        ) {
            Button("Confirm erase session history", role: .destructive, action: clearHistory)
            Button("Keep the paperwork", role: .cancel) {}
        } message: {
            Text("This clears the history but leaves the current timer alone.")
        }
    }

    private var boundaryCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 7) {
                DumbStatusPill("KEEPS COUNTING", systemImage: "livephoto", accent: accent)
                Text("Leave the app or lock your phone—the clock keeps going. Bathroom Ops checks in at 5, 10, 15, and 20 minutes.")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CorpPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("toiletMilestoneSummary")
                Label("See the live timer on your Lock Screen and Dynamic Island when available.", systemImage: "iphone.gen3")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var heroTimerDial: some View {
        TimelineView(.periodic(from: .now, by: 0.5)) { context in
            let elapsed = displayedSeconds(at: context.date)
            DumbCard(accent: accent, isSelected: isRunning || recordedSeconds > 0) {
                VStack(spacing: DumbSpacing.md) {
                    DumbHeroMeter(
                        progress: min(elapsed / 1_200, 1),
                        valueLabel: formattedDuration(elapsed),
                        title: isRunning ? "Stall session live" : recordedSeconds > 0 ? "Last assessed session" : "Timer standing by",
                        subtitle: isRunning ? "Lock Screen timer active when available" : "Tap start below",
                        accent: accent,
                        systemImage: isRunning ? "stopwatch.fill" : "timer",
                        variant: .arc,
                        size: 128
                    )
                    .accessibilityIdentifier("liveTimerReadout")
                }
            }
        }
    }

    private var manualEstimateCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 12) {
                Text("NO LIVE TIMER?")
                    .font(.caption2.weight(.black))
                    .tracking(1.2)
                    .foregroundStyle(CorpPalette.mutedInk)

                DumbSlider(title: "Best guess", value: $minutes, range: 1...60, step: 1, accent: accent)
                    .accessibilityIdentifier("manualMinutesSlider")

                Button(action: assessManualEstimate) {
                    Label("Assess \(Int(minutes))-minute estimate", systemImage: "text.badge.checkmark")
                        .font(.subheadline.weight(.black))
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .foregroundStyle(accent)
                .buttonStyle(DumbPressStyle())
                .accessibilityIdentifier("assessManualEstimateButton")
            }
        }
    }

    private var sessionHistoryCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 11) {
                HStack {
                    Text("COMPLAINT LOG")
                        .font(.caption2.weight(.black))
                        .tracking(1.2)
                        .foregroundStyle(CorpPalette.mutedInk)
                    Spacer()
                    Text("\(sessions.count) filed")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .accessibilityIdentifier("toiletHistoryCount")
                        .accessibilityValue("\(sessions.count)")
                }

                if sessions.isEmpty {
                    Label("No complaints on file.", systemImage: "doc")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(CorpPalette.ink)
                        .accessibilityIdentifier("emptyToiletHistory")
                } else {
                    ForEach(sessions.prefix(10)) { session in
                        HStack(spacing: 10) {
                            Image(systemName: session.mode == "Live" ? "timer" : "slider.horizontal.3")
                                .foregroundStyle(accent)
                                .accessibilityHidden(true)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(session.mode) · \(formattedDuration(session.seconds))")
                                    .font(.subheadline.weight(.black))
                                    .foregroundStyle(CorpPalette.ink)
                                Text(session.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(CorpPalette.mutedInk)
                            }
                            Spacer()
                            Button(role: .destructive) { delete(session) } label: { Image(systemName: "trash") }
                                .accessibilityLabel("Delete bathroom session")
                                .accessibilityIdentifier("deleteToiletSessionButton")
                        }
                    }
                }
            }
        }
    }

    private var hasCurrentSession: Bool {
        isRunning || recordedSeconds > 0 || result != Self.emptyResult
    }

    private func displayedSeconds(at date: Date) -> TimeInterval {
        guard isRunning, let activeStartedAt else { return recordedSeconds }
        return max(0, date.timeIntervalSince(activeStartedAt))
    }

    private func formattedDuration(_ seconds: TimeInterval) -> String {
        let totalSeconds = max(0, Int(seconds.rounded(.down)))
        return String(format: "%02d:%02d", totalSeconds / 60, totalSeconds % 60)
    }

    private func toggleTimer() {
        isRunning ? finishLiveSession() : beginLiveSession()
    }

    private func beginLiveSession() {
        let startedAt = Date()
        let newSessionID = UUID()
        activeStartedAt = startedAt
        sessionID = newSessionID
        recordedSeconds = 0
        isRunning = true
        result = "Timer running. Bathroom Ops is watching the clock."
        persistRunningState()
        Task { await BathroomTimerPresentation.begin(startedAt: startedAt, sessionID: newSessionID) }
    }

    private func finishLiveSession() {
        let seconds = displayedSeconds(at: Date())
        let completedSessionID = sessionID
        recordedSeconds = seconds
        isRunning = false
        activeStartedAt = nil
        sessionID = nil
        persistRunningState()
        assess(seconds: seconds, mode: "Live")
        Task { await BathroomTimerPresentation.finish(sessionID: completedSessionID) }
    }

    private func assessManualEstimate() {
        recordedSeconds = minutes * 60
        assess(seconds: recordedSeconds, mode: "Estimate")
    }

    private func assess(seconds: TimeInterval, mode: String) {
        let assessedMinutes = seconds / 60
        result = assessedMinutes > 20
            ? "You have crossed from bathroom user into bathroom resident."
            : assessedMinutes > 10
                ? "Wrap it up. The grout is starting to know your name."
                : "Acceptable. Leave before anyone gets curious."

        sessions.insert(BathroomSession(seconds: seconds, mode: mode), at: 0)
        sessions = Array(sessions.prefix(20))
        persistSessions()
    }

    private func resetCurrentSession() {
        let abandonedSessionID = sessionID
        activeStartedAt = nil
        sessionID = nil
        recordedSeconds = 0
        isRunning = false
        result = Self.emptyResult
        persistRunningState()
        Task { await BathroomTimerPresentation.finish(sessionID: abandonedSessionID) }
    }

    private func delete(_ session: BathroomSession) {
        sessions.removeAll { $0.id == session.id }
        persistSessions()
    }

    private func clearHistory() {
        sessions = []
        persistSessions()
    }

    private func restoreState() {
        guard !hasLoaded else { return }
        hasLoaded = true
        restoreSessions()

        guard storedIsRunning, storedActiveStartedAt > 0, let restoredSessionID = UUID(uuidString: storedSessionID) else {
            clearStoredRunningState()
            return
        }

        let restoredStart = Date(timeIntervalSince1970: storedActiveStartedAt)
        activeStartedAt = restoredStart
        sessionID = restoredSessionID
        isRunning = true
        result = "Timer running. Bathroom Ops is watching the clock."
        Task { await BathroomTimerPresentation.restore(startedAt: restoredStart, sessionID: restoredSessionID) }
    }

    private func restoreSessions() {
        guard
            let data = storedSessions.data(using: .utf8),
            let saved = try? JSONDecoder().decode([BathroomSession].self, from: data)
        else { return }
        sessions = saved.sorted { $0.date > $1.date }
    }

    private func persistRunningState() {
        storedIsRunning = isRunning
        storedActiveStartedAt = activeStartedAt?.timeIntervalSince1970 ?? 0
        storedSessionID = sessionID?.uuidString ?? ""
    }

    private func clearStoredRunningState() {
        storedIsRunning = false
        storedActiveStartedAt = 0
        storedSessionID = ""
    }

    private func persistSessions() {
        guard
            let data = try? JSONEncoder().encode(sessions),
            let value = String(data: data, encoding: .utf8)
        else { return }
        storedSessions = value
    }
}
