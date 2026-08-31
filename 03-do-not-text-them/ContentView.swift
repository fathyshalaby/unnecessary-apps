import SwiftUI
import UserNotifications
import DumbKit

struct DoNotTextThemView: View {
    @State private var message = ""
    @State private var remaining = 0
    @State private var status = "The tribunal is ready."
    @State private var interventionRevision = 0
    @State private var deadline: Date?
    @State private var countdownTask: Task<Void, Never>?
    @State private var notificationTask: Task<Void, Never>?
    @State private var interventionNotificationID: String?
    @AppStorage("doNotTextThem.completedInterventions") private var completedInterventions = 0
    @AppStorage("doNotTextThem.deletedDrafts") private var deletedDrafts = 0
    @FocusState private var draftIsFocused: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            CorpPalette.canvas.ignoresSafeArea()
            LinearGradient(
                colors: [CorpPalette.emergencyRed.opacity(0.16), CorpPalette.canvas.opacity(0.4), CorpPalette.canvas],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: DumbSpacing.lg) {
                    interventionHeader

                    DumbBoundaryChip(
                        storageKey: "doNotTextThem.boundaryDismissed",
                        message: "Drafts stay on your device — nothing is sent, stored in the cloud, or shared.",
                        accent: CorpPalette.emergencyRed,
                        systemImage: "hand.raised.fill"
                    )

                    DumbCard {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("DRAFT EVIDENCE")
                                    .font(.caption2.weight(.black))
                                    .tracking(1.2)
                                    .foregroundStyle(CorpPalette.mutedInk)
                                Spacer()
                                Text("\(message.count)/2,000")
                                    .font(.caption2.monospacedDigit().weight(.bold))
                                    .foregroundStyle(CorpPalette.mutedInk)
                            }
                            TextEditor(text: $message)
                                .frame(minHeight: 200)
                                .scrollContentBackground(.hidden)
                                .padding(8)
                                .background(CorpPalette.canvas, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                                .focused($draftIsFocused)
                                .accessibilityLabel("Draft evidence")
                                .accessibilityHint("Enter the message you are considering sending. Maximum 2,000 characters.")
                                .accessibilityIdentifier("draftEditor")
                                .onChange(of: message) { _, newValue in
                                    guard newValue.count > 2_000 else { return }
                                    message = String(newValue.prefix(2_000))
                                }
                            Label("Write it here. Nothing gets sent.", systemImage: "hand.raised.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(CorpPalette.mutedInk)
                        }
                    }

                    if remaining > 0 {
                        countdownCard
                            .transition(.scale(scale: 0.96).combined(with: .opacity))
                    }

                    Button {
                        deleteEvidence()
                    } label: {
                        Label("Delete evidence", systemImage: "trash.fill")
                            .font(.subheadline.weight(.black))
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .foregroundStyle(CorpPalette.emergencyRed)
                    .buttonStyle(DumbPressStyle())
                    .disabled(message.isEmpty && remaining == 0)
                    .accessibilityIdentifier("deleteEvidenceButton")

                    rescueStats

                    DumbNativeTip(
                        "Siri & Shortcuts",
                        detail: "Say “Start intervention in Do Not Text Them,” add the Shortcuts action, or Handoff a draft from another device.",
                        systemImage: "hand.raised.fill",
                        accent: CorpPalette.emergencyRed
                    )
                }
                .padding(.horizontal, DumbSpacing.md)
                .padding(.top, DumbSpacing.sm)
                .padding(.bottom, DumbSpacing.xxl)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(spacing: DumbSpacing.sm) {
                    DumbAction(
                        title: remaining > 0 ? "Breathe. \(remaining)s" : "Start the cool-off",
                        accent: CorpPalette.emergencyRed,
                        systemImage: "shield.fill"
                    ) {
                        startIntervention()
                    }
                    .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || remaining > 0)
                    .accessibilityIdentifier("startInterventionButton")

                    DumbResult(
                        text: status,
                        accent: CorpPalette.emergencyRed,
                        systemImage: "hand.raised.fill",
                        reactionStyle: .shake
                    )

                    if status != "The tribunal is ready." && status != "Cool-off aborted. The draft remains yours—use wisely." {
                        DumbShareVerdict(
                            text: status,
                            subject: "Do not text them — intervention",
                            accent: CorpPalette.emergencyRed,
                            accessibilityIdentifier: "shareInterventionStatusButton"
                        )
                    }
                }
                .padding(.horizontal, DumbSpacing.md)
                .padding(.vertical, DumbSpacing.sm)
                .background(CorpPalette.canvas.opacity(0.96))
            }
        }
        .tint(CorpPalette.emergencyRed)
        .environment(\.dumbExperienceStyle, .timer)
        .dumbNativeEntry(scheme: "app03donottextthem", onRoute: handleNativeRoute)
        .dumbHandoffDraft(
            "corp.unecessary.app03.draft",
            title: "Do Not Text Them draft",
            isActive: !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            payload: ["message": message]
        ) { userInfo in
            if let restored = userInfo["message"], !restored.isEmpty {
                message = restored
            }
        }
        .onAppear {
            resumeIntervention()
            syncWidgetSnapshot()
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                resumeIntervention()
            default:
                // Preserve the real deadline, but stop polling while hidden.
                countdownTask?.cancel()
                countdownTask = nil
            }
        }
        .onDisappear {
            countdownTask?.cancel()
            countdownTask = nil
        }
    }

    private var interventionHeader: some View {
        HStack(alignment: .top, spacing: DumbSpacing.sm) {
            VStack(alignment: .leading, spacing: 6) {
                Text("DO NOT TEXT THEM")
                    .font(.caption.weight(.black))
                    .tracking(1.4)
                    .foregroundStyle(CorpPalette.emergencyRed)
                Text("Put the phone down.")
                    .font(.system(.title, design: .rounded).weight(.black))
                    .foregroundStyle(CorpPalette.ink)
                    .accessibilityAddTraits(.isHeader)
                Text("Your dignity has requested a cooling-off period.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(CorpPalette.mutedInk)
            }
            Spacer(minLength: 0)
            Image("AppMascot", bundle: .main)
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
                .padding(6)
                .background(CorpPalette.emergencyRed.opacity(0.12), in: Circle())
                .overlay(Circle().stroke(CorpPalette.emergencyRed.opacity(0.22), lineWidth: 2))
                .rotationEffect(.degrees(-6))
                .accessibilityHidden(true)
        }
    }

    private var rescueStats: some View {
        DumbCard {
            HStack(spacing: 12) {
                stat(
                    value: completedInterventions,
                    label: "COOL-OFFS",
                    systemImage: "timer"
                )
                Divider()
                    .frame(height: 48)
                stat(
                    value: deletedDrafts,
                    label: "DRAFTS DELETED",
                    systemImage: "trash.fill"
                )
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(completedInterventions) completed cool-offs. \(deletedDrafts) drafts deleted.")
        .accessibilityIdentifier("rescueStats")
    }

    private func stat(value: Int, label: String, systemImage: String) -> some View {
        HStack(spacing: 9) {
            Image(systemName: systemImage)
                .font(.headline.weight(.black))
                .foregroundStyle(CorpPalette.emergencyRed)
                .frame(width: 34, height: 34)
                .background(CorpPalette.emergencyRed.opacity(0.12), in: Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 1) {
                Text("\(value)")
                    .font(.system(.title3, design: .rounded).weight(.black))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                Text(label)
                    .font(.caption2.weight(.black))
                    .tracking(0.7)
                    .foregroundStyle(CorpPalette.mutedInk)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var countdownCard: some View {
        DumbCard(accent: CorpPalette.emergencyRed, isSelected: true) {
            HStack(spacing: 18) {
                ZStack {
                    Circle()
                        .stroke(CorpPalette.emergencyRed.opacity(0.15), lineWidth: 9)
                    Circle()
                        .trim(from: 0, to: CGFloat(remaining) / 10)
                        .stroke(
                            CorpPalette.emergencyRed,
                            style: StrokeStyle(lineWidth: 9, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    Text("\(remaining)")
                        .font(.system(.title, design: .rounded).weight(.black))
                        .foregroundStyle(CorpPalette.emergencyRed)
                        .monospacedDigit()
                        .contentTransition(.numericText(countsDown: true))
                }
                .frame(width: 84, height: 84)
                .animation(reduceMotion ? nil : .linear(duration: 0.28), value: remaining)

                VStack(alignment: .leading, spacing: 6) {
                    Text("COOLING-OFF CLOCK")
                        .font(.caption2.weight(.black))
                        .tracking(1.2)
                        .foregroundStyle(CorpPalette.emergencyRed)
                    Text(countdownCaption)
                        .font(.headline.weight(.black))
                        .foregroundStyle(CorpPalette.ink)
                        .contentTransition(.opacity)
                    Button(action: abortIntervention) {
                        Label("Abort cool-off", systemImage: "xmark.circle.fill")
                            .font(.caption.weight(.black))
                            .frame(maxWidth: .infinity, minHeight: DumbMetrics.minimumTapTarget)
                    }
                    .foregroundStyle(CorpPalette.emergencyRed)
                    .buttonStyle(DumbPressStyle())
                    .accessibilityIdentifier("abortInterventionButton")
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(remaining) seconds remaining. \(countdownCaption)")
    }

    private var mascotCaption: String {
        if remaining > 0 { return "Do not touch Send. I have seen this movie." }
        if message.isEmpty { return "I cannot save you from a message you have not typed." }
        return "Draft detected. Emergency protocol available."
    }

    private var countdownCaption: String {
        switch remaining {
        case 8...10: return "Separate the thumb from the bad idea."
        case 4...7: return "The message is getting less charming by the second."
        case 1...3: return "Future you is almost safe."
        default: return "Crisis downgraded."
        }
    }

    private func syncWidgetSnapshot() {
        DumbWidgetSync.publish(.doNotTextThem, values: [
            "remaining": "\(remaining)",
            "active": remaining > 0 ? "1" : "0",
        ])
    }

    private func handleNativeRoute(_ action: String, _ payload: String) {
        switch action {
        case "start":
            if !payload.isEmpty {
                message = payload
            }
            guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, remaining == 0 else { return }
            startIntervention()
        default:
            break
        }
    }

    private func startIntervention() {
        countdownTask?.cancel()
        draftIsFocused = false
        let expiration = Date().addingTimeInterval(10)
        deadline = expiration
        let notificationID = "doNotTextThem.cooldown.\(UUID().uuidString)"
        interventionNotificationID = notificationID
        withAnimation(reduceMotion ? nil : DumbMotion.playful) {
            remaining = 10
            status = "Step 1: You do not miss them. You miss being perceived."
            interventionRevision += 1
        }
        syncWidgetSnapshot()
        notificationTask?.cancel()
        notificationTask = Task { @MainActor in
            await scheduleCompletionNotification(id: notificationID, fireDate: expiration)
        }
        startCountdown()
    }

    private func resumeIntervention() {
        guard deadline != nil else { return }
        refreshCountdown()
        guard deadline != nil, remaining > 0, countdownTask == nil else { return }
        startCountdown()
    }

    private func startCountdown() {
        countdownTask?.cancel()
        countdownTask = Task { @MainActor in
            while !Task.isCancelled, deadline != nil {
                refreshCountdown()
                guard deadline != nil else { return }
                try? await Task.sleep(for: .milliseconds(200))
            }
        }
    }

    private func refreshCountdown() {
        guard let deadline else { return }
        let nextRemaining = max(0, Int(ceil(deadline.timeIntervalSinceNow)))
        guard nextRemaining != remaining else { return }

        if nextRemaining == 0 {
            completeIntervention()
            return
        }

        withAnimation(reduceMotion ? nil : DumbMotion.quick) {
            remaining = nextRemaining
            switch nextRemaining {
            case 8...10:
                status = "Step 1: You do not miss them. You miss being perceived."
            case 4...7:
                status = "Step 2: Read the message out loud. Horrifying, isn’t it?"
            default:
                status = "Step 3: Your future self has entered the room."
            }
        }
        syncWidgetSnapshot()
    }

    private func abortIntervention() {
        cancelCompletionNotification()
        countdownTask?.cancel()
        countdownTask = nil
        deadline = nil
        withAnimation(reduceMotion ? nil : DumbMotion.playful) {
            remaining = 0
            status = "Cool-off aborted. The draft remains yours—use wisely."
            interventionRevision += 1
        }
        syncWidgetSnapshot()
    }

    private func completeIntervention() {
        cancelCompletionNotification()
        countdownTask?.cancel()
        countdownTask = nil
        deadline = nil
        completedInterventions += 1
        withAnimation(reduceMotion ? nil : DumbMotion.playful) {
            remaining = 0
            status = "Intervention complete. Delete it. Be mysterious."
            interventionRevision += 1
        }
        syncWidgetSnapshot()
    }

    private func deleteEvidence() {
        let hadEvidence = !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        cancelCompletionNotification()
        countdownTask?.cancel()
        countdownTask = nil
        deadline = nil
        draftIsFocused = false
        if hadEvidence {
            deletedDrafts += 1
        }
        withAnimation(reduceMotion ? nil : DumbMotion.playful) {
            message = ""
            remaining = 0
            status = "A narrow escape. The court is adjourned."
            interventionRevision += 1
        }
    }

    private func cancelCompletionNotification() {
        notificationTask?.cancel()
        notificationTask = nil
        if let interventionNotificationID {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [interventionNotificationID])
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [interventionNotificationID])
        }
        interventionNotificationID = nil
    }

    private func scheduleCompletionNotification(id: String, fireDate: Date) async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        var canNotify = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional

        if settings.authorizationStatus == .notDetermined {
            canNotify = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        }
        guard canNotify, !Task.isCancelled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Cooling-off complete"
        content.body = "The tribunal has released the draft for review."
        content.sound = .default
        content.userInfo = [DumbNativeRoute.userInfoKey: "open:"]
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(1, fireDate.timeIntervalSinceNow),
            repeats: false
        )
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try? await center.add(request)
    }
}

#if canImport(PreviewsMacros)
#Preview { DoNotTextThemView() }
#endif
