import HealthKit
import SwiftUI
import DumbKit

@main
struct RecoveryGoblinApp: App {
    var body: some Scene {
        WindowGroup { RecoveryGoblinView().dumbNativeEntry(scheme: "app41recoverygoblin") { _, _ in } }
    }
}

struct RecoveryGoblinView: View {
    @AppStorage("recoveryGoblin.tiredness") private var tiredness = 7.0
    @AppStorage("recoveryGoblin.soreness") private var soreness = 6.0
    @AppStorage("recoveryGoblin.result") private var result = "The goblin is hiding behind the foam roller."
    @AppStorage("recoveryGoblin.healthConnected") private var healthConnected = false
    @AppStorage("recoveryGoblin.dailyNudgeEnabled") private var dailyNudgeEnabled = false
    @AppStorage("recoveryGoblin.nudgeHour") private var nudgeHour = 19
    @AppStorage("recoveryGoblin.nudgeMinute") private var nudgeMinute = 0

    @State private var healthWorkoutMinutes: Double?
    @State private var healthStatus = "Apple Health is optional. The goblin cannot measure recovery."
    @State private var isLoadingHealth = false
    @State private var notificationMessage = "Off. The goblin does not send deputies."
    @State private var nudgeDate = Date()
    @State private var didLoadNudgeDate = false

    private let accent = CorpPalette.parkGreen
    private let healthStore = HKHealthStore()
    private static let notificationIdentifier = "recovery-goblin.daily-check-in"

    private var workoutType: HKWorkoutType {
        HKObjectType.workoutType()
    }

    var body: some View {
        AppCanvas(accent: accent, experience: .wellness) {
            AppHeader(
                eyebrow: "GOBLIN RECOVERY SERVICES",
                title: "The recovery goblin",
                subtitle: "A small creature for a kinder check-in, not a coach.",
                accent: accent
            )

            healthConnectionCard
            checkInCard

            notificationCard

            Button(action: reset) {
            Label("Reset the goblin", systemImage: "arrow.counterclockwise")
            .font(.subheadline.weight(.black))
            .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .accessibilityIdentifier("resetRecoveryGoblinButton")

        } bottomBar: {
            DumbAction(
            title: "Ask the goblin",
            accent: accent,
            systemImage: "questionmark.circle.fill",
            action: askGoblin
            )
            .accessibilityIdentifier("askRecoveryGoblinButton")

            DumbResult(text: result, accent: accent, systemImage: "leaf.fill", reactionStyle: .bounce)
            .accessibilityIdentifier("recoveryGoblinResult")

        }
        .onAppear {
            loadNudgeDate()
            if healthConnected { importHealthWorkouts() }
        }
        .onChange(of: dailyNudgeEnabled) { _, enabled in
            if enabled {
                scheduleDailyNudge()
            } else {
                DumbLocalNotifications.cancel(identifier: Self.notificationIdentifier)
                notificationMessage = "Off. The goblin does not send deputies."
            }
        }
        .onChange(of: nudgeDate) { _, date in
            guard didLoadNudgeDate else { return }
            let calendar = Calendar.autoupdatingCurrent
            nudgeHour = calendar.component(.hour, from: date)
            nudgeMinute = calendar.component(.minute, from: date)
            if dailyNudgeEnabled { scheduleDailyNudge() }
        }
    }

    private var healthConnectionCard: some View {
        DumbCard(accent: accent, isSelected: healthWorkoutMinutes != nil) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.title2.weight(.black))
                        .foregroundStyle(accent)
                        .frame(width: 54, height: 54)
                        .background(accent.opacity(0.14), in: Circle())
                    VStack(alignment: .leading, spacing: 3) {
                        Text(healthWorkoutMinutes == nil ? "OPTIONAL MOVEMENT CONTEXT" : "MOVEMENT CONTEXT RECEIVED")
                            .font(.caption2.weight(.black))
                            .tracking(1.1)
                            .foregroundStyle(accent)
                        Text(healthWorkoutMinutes == nil ? "Let the watch brief the goblin." : "The goblin read the activity log.")
                            .font(.headline.weight(.black))
                            .foregroundStyle(CorpPalette.ink)
                    }
                }

                Button(action: importHealthWorkouts) {
                    Label(
                        isLoadingHealth ? "Checking Apple Health…" : healthWorkoutMinutes == nil ? "Connect Apple Health" : "Refresh movement context",
                        systemImage: isLoadingHealth ? "hourglass" : "heart.text.square.fill"
                    )
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
                }
                .foregroundStyle(accent)
                .buttonStyle(DumbPressStyle())
                .disabled(isLoadingHealth)
                .accessibilityIdentifier("importRecoveryHealthButton")

                Text(healthWorkoutMinutes == nil ? healthStatus : "Read-only workout duration is context, not a recovery score.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("recoveryGoblinHealthCard")
    }

    private var checkInCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 12) {
                DumbStatusPill("YOUR CHECK-IN", systemImage: "face.smiling.fill", accent: accent)
                DumbSlider(title: "Tiredness: \(Int(tiredness.rounded())) / 10", value: $tiredness, range: 0...10, step: 1, accent: accent)
                DumbSlider(title: "Soreness: \(Int(soreness.rounded())) / 10", value: $soreness, range: 0...10, step: 1, accent: accent)
                Text("These are your own signals. The goblin offers a playful option; it does not diagnose or prescribe.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("recoveryGoblinInputs")
    }

    private var notificationCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: "bell.badge.fill")
                        .font(.title3.weight(.black))
                        .foregroundStyle(accent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("GOBLIN CHECK-IN")
                            .font(.caption2.weight(.black))
                            .tracking(1.1)
                            .foregroundStyle(accent)
                        Text("One optional evening reminder to report your own signals.")
                            .font(.subheadline.weight(.black))
                            .foregroundStyle(CorpPalette.ink)
                    }
                }
                Toggle("Remind me to check in", isOn: $dailyNudgeEnabled)
                    .font(.subheadline.weight(.black))
                    .tint(accent)
                    .accessibilityIdentifier("recoveryGoblinDailyNudgeSwitch")
                DatePicker("Check-in time", selection: $nudgeDate, displayedComponents: .hourAndMinute)
                    .font(.subheadline.weight(.bold))
                    .disabled(!dailyNudgeEnabled)
                    .accessibilityIdentifier("recoveryGoblinNudgeTimePicker")
                Text(notificationMessage)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("recoveryGoblinNotificationCard")
    }

    private func askGoblin() {
        let context = healthWorkoutMinutes.map { " The goblin noticed \(Int($0.rounded())) minutes in the activity log." } ?? ""
        result = tiredness + soreness > 14
            ? "The goblin says: permission to take it extremely easy granted.\(context)"
            : tiredness + soreness > 8
                ? "The goblin recommends a low-key day and a snack, as a tiny opinion—not an instruction.\(context)"
                : "The goblin finds no dramatic paperwork. Choose whatever gentle plan feels right.\(context)"
    }

    private func reset() {
        tiredness = 7
        soreness = 6
        result = "The goblin is hiding behind the foam roller."
        healthWorkoutMinutes = nil
        healthConnected = false
        manualMode = false
        healthStatus = "Apple Health is optional. The goblin cannot measure recovery."
        dailyNudgeEnabled = false
        DumbLocalNotifications.cancel(identifier: Self.notificationIdentifier)
        notificationMessage = "Off. The goblin does not send deputies."
    }

    private func importHealthWorkouts() {
        guard HKHealthStore.isHealthDataAvailable() else {
            healthStatus = "Apple Health is unavailable here. Your own check-in still works."
            return
        }

        isLoadingHealth = true
        healthStore.requestAuthorization(toShare: [], read: [workoutType]) { success, error in
            guard success, error == nil else {
                DispatchQueue.main.async {
                    isLoadingHealth = false
                    healthStatus = "Apple Health wasn’t shared. Your own check-in still works."
                }
                return
            }

            let end = Date()
            let start = Calendar.autoupdatingCurrent.startOfDay(for: end)
            let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
            let query = HKSampleQuery(
                sampleType: workoutType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                guard error == nil else {
                    DispatchQueue.main.async {
                        isLoadingHealth = false
                        healthStatus = "Apple Health could not be read right now. Your own check-in still works."
                    }
                    return
                }
                let workoutMinutes = (samples as? [HKWorkout] ?? []).reduce(0.0) { $0 + $1.duration / 60 }
                DispatchQueue.main.async {
                    isLoadingHealth = false
                    if workoutMinutes > 0 {
                        healthWorkoutMinutes = workoutMinutes
                        healthConnected = true
                        healthStatus = "Using today’s read-only activity context from Apple Health."
                    } else {
                        healthWorkoutMinutes = nil
                        healthConnected = true
                        healthStatus = "No workout arrived from Apple Health. Your own check-in still works."
                    }
                }
            }
            healthStore.execute(query)
        }
    }

    private func loadNudgeDate() {
        guard !didLoadNudgeDate else { return }
        didLoadNudgeDate = true
        nudgeDate = Calendar.autoupdatingCurrent.date(
            bySettingHour: nudgeHour,
            minute: nudgeMinute,
            second: 0,
            of: Date()
        ) ?? Date()
    }

    private func scheduleDailyNudge() {
        let date = Calendar.autoupdatingCurrent.date(
            bySettingHour: nudgeHour,
            minute: nudgeMinute,
            second: 0,
            of: Date()
        ) ?? Date()
        notificationMessage = "Asking for permission, then scheduling one quiet-hours-aware goblin check-in."
        Task {
            let outcome = await DumbLocalNotifications.scheduleDaily(
                identifier: Self.notificationIdentifier,
                title: "The recovery goblin is checking in",
                body: "Your own tiny check-in is waiting. The goblin has no medical qualifications.",
                proposedTime: date
            )
            await MainActor.run {
                switch outcome {
                case .scheduled(let scheduledDate):
                    notificationMessage = "One goblin check-in scheduled for \(scheduledDate.formatted(date: .omitted, time: .shortened))."
                case .denied:
                    dailyNudgeEnabled = false
                    notificationMessage = "Notifications are off in Settings. The goblin still works without them."
                case .failed:
                    dailyNudgeEnabled = false
                    notificationMessage = "The goblin reminder did not stick. The goblin still works without it."
                }
            }
        }
    }
}
