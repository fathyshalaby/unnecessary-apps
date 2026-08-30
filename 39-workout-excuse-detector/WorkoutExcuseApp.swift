import HealthKit
import SwiftUI
import DumbKit

@main
struct WorkoutExcuseApp: App {
    var body: some Scene {
        WindowGroup { WorkoutExcuseView().dumbNativeEntry(scheme: "app39workoutexcuse") { _, _ in } }
    }
}

struct WorkoutExcuseView: View {
    @AppStorage("workoutExcuse.excuse") private var excuse = "I was too busy"
    @AppStorage("workoutExcuse.minutes") private var minutes = 12.0
    @AppStorage("workoutExcuse.result") private var result = "No excuse submitted. The detector is hungry."
    @AppStorage("workoutExcuse.healthConnected") private var healthConnected = false
    @AppStorage("workoutExcuse.manualMode") private var manualMode = false
    @AppStorage("workoutExcuse.dailyNudgeEnabled") private var dailyNudgeEnabled = false
    @AppStorage("workoutExcuse.nudgeHour") private var nudgeHour = 18
    @AppStorage("workoutExcuse.nudgeMinute") private var nudgeMinute = 0

    @State private var healthWorkoutMinutes: Double?
    @State private var healthStatus = "Manual movement still works. Apple Health is optional."
    @State private var isLoadingHealth = false
    @State private var manualEditorVisible = false
    @State private var notificationMessage = "Off. The detector will not chase you."
    @State private var nudgeDate = Date()
    @State private var didLoadNudgeDate = false

    private let accent = CorpPalette.warningRed
    private let healthStore = HKHealthStore()
    private static let notificationIdentifier = "workout-excuse.daily-check-in"

    private var forceFallbackForUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("-UITestingForceFallback")
    }

    private var workoutType: HKWorkoutType {
        HKObjectType.workoutType()
    }

    private var effectiveMinutes: Double {
        healthWorkoutMinutes ?? minutes
    }

    var body: some View {
        DumbShell(
            eyebrow: "EXCUSE FORENSICS",
            title: "Workout excuse detector",
            subtitle: "A playful cross-examination of the sentence you told yourself.",
            accent: accent,
            personality: .chaotic,
            experience: .meter
        ) {
            caseCard
            healthConnectionCard
            evidenceCard

            DumbAction(
                title: "Run the detector",
                accent: accent,
                systemImage: "magnifyingglass",
                action: runDetector
            )
            .accessibilityIdentifier("runWorkoutExcuseButton")

            DumbResult(text: result, accent: accent, systemImage: "doc.text.magnifyingglass", reactionStyle: .shake)
                .accessibilityIdentifier("workoutExcuseResult")

            notificationCard
            manualMovementCard

            Button(action: reset) {
                Label("Reset the case", systemImage: "arrow.counterclockwise")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .accessibilityIdentifier("resetWorkoutExcuseButton")
        }
        .onAppear {
            loadNudgeDate()
            if healthConnected && !manualMode { importHealthWorkouts() }
            if manualMode {
                manualEditorVisible = true
                healthStatus = "Manual movement active. Apple Health remains optional."
            }
        }
        .onChange(of: dailyNudgeEnabled) { _, enabled in
            if enabled {
                scheduleDailyNudge()
            } else {
                DumbLocalNotifications.cancel(identifier: Self.notificationIdentifier)
                notificationMessage = "Off. The detector will not chase you."
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

    private var caseCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 10) {
                DumbStatusPill("THE CASE", systemImage: "doc.text.fill", accent: accent)
                DumbField("Your excuse", maxLength: 180, text: $excuse)
                Text("The detector checks the story against movement you share or enter. It issues jokes, not training advice.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("workoutExcuseInputs")
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
                        Text(healthWorkoutMinutes == nil ? "APPLE HEALTH EVIDENCE" : "EVIDENCE RECEIVED")
                            .font(.caption2.weight(.black))
                            .tracking(1.1)
                            .foregroundStyle(accent)
                        Text(healthWorkoutMinutes == nil ? "Let the watch take the stand." : "Today’s workouts are in evidence.")
                            .font(.headline.weight(.black))
                            .foregroundStyle(CorpPalette.ink)
                    }
                }

                Button(action: importHealthWorkouts) {
                    Label(
                        isLoadingHealth ? "Checking Apple Health…" : healthWorkoutMinutes == nil ? "Use Apple Health workouts" : "Refresh workout evidence",
                        systemImage: isLoadingHealth ? "hourglass" : "heart.text.square.fill"
                    )
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
                }
                .foregroundStyle(accent)
                .buttonStyle(DumbPressStyle())
                .disabled(isLoadingHealth)
                .accessibilityIdentifier("importHealthWorkoutsButton")

                Text(healthWorkoutMinutes == nil ? healthStatus : "Read-only workout duration. It is not a performance score.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("workoutExcuseHealthCard")
    }

    private var evidenceCard: some View {
        DumbCard(accent: accent, isSelected: effectiveMinutes > 10) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: effectiveMinutes > 10 ? "checkmark.seal.fill" : "questionmark.diamond.fill")
                    .font(.title2.weight(.black))
                    .foregroundStyle(accent)
                VStack(alignment: .leading, spacing: 4) {
                    Text(healthWorkoutMinutes == nil ? "MANUAL MOVEMENT" : "MOVEMENT EVIDENCE")
                        .font(.caption2.weight(.black))
                        .tracking(1.1)
                        .foregroundStyle(accent)
                    Text("\(Int(effectiveMinutes.rounded())) minutes logged")
                        .font(.title3.weight(.black))
                        .foregroundStyle(CorpPalette.ink)
                    Text(effectiveMinutes > 10 ? "Enough evidence to downgrade a few excuses." : "A light paper trail. The defense may continue.")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CorpPalette.mutedInk)
                }
                Spacer(minLength: 0)
            }
        }
        .accessibilityIdentifier("workoutExcuseEvidenceCard")
    }

    private var notificationCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: "bell.badge.fill")
                        .font(.title3.weight(.black))
                        .foregroundStyle(accent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CASE CHECK-IN")
                            .font(.caption2.weight(.black))
                            .tracking(1.1)
                            .foregroundStyle(accent)
                        Text("One optional nudge to submit today’s story.")
                            .font(.subheadline.weight(.black))
                            .foregroundStyle(CorpPalette.ink)
                    }
                }
                Toggle("Remind me to check in", isOn: $dailyNudgeEnabled)
                    .font(.subheadline.weight(.black))
                    .tint(accent)
                    .accessibilityIdentifier("workoutExcuseDailyNudgeSwitch")
                DatePicker("Check-in time", selection: $nudgeDate, displayedComponents: .hourAndMinute)
                    .font(.subheadline.weight(.bold))
                    .disabled(!dailyNudgeEnabled)
                    .accessibilityIdentifier("workoutExcuseNudgeTimePicker")
                Text(notificationMessage)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("workoutExcuseNotificationCard")
    }

    private var manualMovementCard: some View {
        DumbCard(accent: accent) {
            DisclosureGroup(isExpanded: $manualEditorVisible) {
                DumbSlider(
                    title: "Manual movement: \(Int(minutes.rounded())) minutes",
                    value: $minutes,
                    range: 0...180,
                    step: 1,
                    accent: accent
                )
                .padding(.top, 10)
                .disabled(healthWorkoutMinutes != nil)
                .accessibilityIdentifier("workoutExcuseManualSlider")

                if healthWorkoutMinutes != nil {
                    Button("Switch to manual movement") {
                        healthWorkoutMinutes = nil
                        manualMode = true
                        manualEditorVisible = true
                        healthStatus = "Manual movement active. Apple Health remains optional."
                    }
                    .font(.caption.weight(.black))
                    .foregroundStyle(accent)
                    .buttonStyle(DumbPressStyle())
                } else {
                    Text("Manual movement is the backup for no data, simulator use, or a story you want to enter yourself.")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } label: {
                Label("Enter movement manually", systemImage: "slider.horizontal.3")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(CorpPalette.ink)
            }
        }
        .accessibilityIdentifier("workoutExcuseManualCard")
    }

    private func runDetector() {
        let cleanExcuse = excuse.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanExcuse.isEmpty else {
            result = "No excuse submitted. The detector cannot cross-examine an empty sentence."
            return
        }
        let lower = cleanExcuse.lowercased()
        let movement = Int(effectiveMinutes.rounded())

        if movement > 10 {
            if lower.contains("tired") || lower.contains("exhaust") {
                result = "The evidence shows \(movement) minutes of movement despite ‘tired.’ The excuse is downgraded to ‘dramatic but technically possible.’"
            } else if lower.contains("injur") || lower.contains("hurt") || lower.contains("sore") {
                result = "Movement was logged, but the injury story stays on file. The detector recommends gentle honesty, not a lecture."
            } else if lower.contains("busy") || lower.contains("meeting") || lower.contains("work") {
                result = "\(movement) minutes of movement suggest the calendar and the excuse are negotiating. Verdict: partially compatible."
            } else {
                result = "The evidence shows \(movement) minutes of movement. Your excuse is downgraded to ‘technically true.’"
            }
            return
        }

        if lower.contains("rain") || lower.contains("weather") {
            result = "Weather defense noted with only \(movement) minutes of movement. The sky cannot be cross-examined, but the record stands."
        } else if lower.contains("later") || lower.contains("tomorrow") {
            result = "A future-workout promise with \(movement) minutes today. The detector files this under ‘pending fiction.’"
        } else {
            result = "The evidence is weak (\(movement) min). The excuse has been admitted into the record without endorsement."
        }
    }

    private func reset() {
        excuse = "I was too busy"
        minutes = 12
        result = "No excuse submitted. The detector is hungry."
        healthWorkoutMinutes = nil
        healthStatus = "Manual movement still works. Apple Health is optional."
        manualMode = false
        manualEditorVisible = false
        dailyNudgeEnabled = false
        DumbLocalNotifications.cancel(identifier: Self.notificationIdentifier)
        notificationMessage = "Off. The detector will not chase you."
    }

    private func importHealthWorkouts() {
        manualMode = false

        if forceFallbackForUITesting {
            healthWorkoutMinutes = nil
            isLoadingHealth = false
            manualEditorVisible = true
            healthStatus = "Manual movement still works. HealthKit fallback is active for this test."
            return
        }

        guard HKHealthStore.isHealthDataAvailable() else {
            manualEditorVisible = true
            healthStatus = "Manual movement still works. Apple Health isn’t available here."
            return
        }

        isLoadingHealth = true
        healthStore.requestAuthorization(toShare: [], read: [workoutType]) { success, error in
            guard success, error == nil else {
                DispatchQueue.main.async {
                    isLoadingHealth = false
                    manualEditorVisible = true
                    healthStatus = "Manual movement still works. Apple Health wasn’t shared."
                }
                return
            }

            let end = Date()
            let start = Calendar.autoupdatingCurrent.startOfDay(for: end)
            let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
            let query = HKSampleQuery(
                sampleType: workoutType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sort]
            ) { _, samples, error in
                guard error == nil else {
                    DispatchQueue.main.async {
                        healthWorkoutMinutes = nil
                        isLoadingHealth = false
                        manualEditorVisible = true
                        healthStatus = "Apple Health could not be read right now. Enter movement below."
                    }
                    return
                }

                let workoutMinutes = (samples as? [HKWorkout] ?? []).reduce(0.0) { total, workout in
                    total + workout.duration / 60
                }

                DispatchQueue.main.async {
                    isLoadingHealth = false
                    if workoutMinutes > 0 {
                        healthWorkoutMinutes = workoutMinutes
                        healthConnected = true
                        healthStatus = "Using today’s read-only workout duration from Apple Health."
                    } else {
                        healthWorkoutMinutes = nil
                        healthConnected = true
                        manualEditorVisible = true
                        healthStatus = "Manual movement still works. No workout arrived from Apple Health."
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
        notificationMessage = "Asking for permission, then scheduling one quiet-hours-aware case check-in."
        Task {
            let outcome = await DumbLocalNotifications.scheduleDaily(
                identifier: Self.notificationIdentifier,
                title: "Workout Excuse case check-in",
                body: "The evidence desk is open whenever you want to submit today’s story.",
                proposedTime: date
            )
            await MainActor.run {
                switch outcome {
                case .scheduled(let scheduledDate):
                    notificationMessage = "One case check-in scheduled for \(scheduledDate.formatted(date: .omitted, time: .shortened))."
                case .denied:
                    dailyNudgeEnabled = false
                    notificationMessage = "Notifications are off in Settings. The detector still works without them."
                case .failed:
                    dailyNudgeEnabled = false
                    notificationMessage = "The check-in did not stick. The detector still works without it."
                }
            }
        }
    }
}
