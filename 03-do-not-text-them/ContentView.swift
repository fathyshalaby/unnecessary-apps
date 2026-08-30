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
        DumbShell(
            eyebrow: "DO NOT TEXT THEM",
            title: "Put the phone down.",
            subtitle: "Your dignity has requested a cooling-off period.",
            accent: CorpPalette.emergencyRed,
            personality: .dramatic
        ) {
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
                        .frame(minHeight: 150)
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

            DumbAction(
                title: remaining > 0 ? "Breathe. \(remaining)s" : "Start intervention",
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

            DumbCharacterStage(
                accent: CorpPalette.emergencyRed,
                title: remaining > 0 ? "Intervention in progress" : "Dignity protection officer",
                caption: mascotCaption,
                reactionTrigger: interventionRevision,
                reactionStyle: .shake
            )
        }
        .onAppear {
            resumeIntervention()
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
