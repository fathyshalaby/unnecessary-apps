import HealthKit
import SwiftUI
import DumbKit

@main
struct RestDayPoliceApp: App {
    var body: some Scene {
        WindowGroup { RestDayPoliceView() }
    }
}

struct RestDayPoliceView: View {
    @AppStorage("restDayPolice.streak") private var streak = 6.0
    @AppStorage("restDayPolice.result") private var result = "No training record. No officers dispatched."
    @AppStorage("restDayPolice.healthConnected") private var healthConnected = false
    @AppStorage("restDayPolice.manualMode") private var manualMode = false
    @AppStorage("restDayPolice.dailyNudgeEnabled") private var dailyNudgeEnabled = false
    @AppStorage("restDayPolice.nudgeHour") private var nudgeHour = 18
    @AppStorage("restDayPolice.nudgeMinute") private var nudgeMinute = 0

    @State private var healthStreak: Int?
    @State private var healthStatus = "Apple Health is optional. You can enter a fictional streak."
    @State private var isLoadingHealth = false
    @State private var manualEditorVisible = false
    @State private var notificationMessage = "Off. The officers will not visit your lock screen."
    @State private var nudgeDate = Date()
    @State private var didLoadNudgeDate = false

    private let accent = CorpPalette.emergencyRed
    private let healthStore = HKHealthStore()
    private static let notificationIdentifier = "rest-day-police.daily-check-in"

    private var workoutType: HKWorkoutType {
        HKObjectType.workoutType()
    }

    private var effectiveStreak: Int {
        healthStreak ?? Int(streak.rounded())
    }

    var body: some View {
        DumbShell(
            eyebrow: "RECOVERY ENFORCEMENT",
            title: "Rest day police",
            subtitle: "A fictional citation for taking your foot off the accelerator.",
            accent: accent,
            personality: .dramatic,
            experience: .wellness
        ) {
            healthConnectionCard
            streakCard

            DumbAction(
                title: "Issue citation",
                accent: accent,
                systemImage: "figure.cooldown",
                action: issueCitation
            )
            .accessibilityIdentifier("issueRestDayCitationButton")

            DumbResult(text: result, accent: accent, systemImage: "checkmark.shield.fill", reactionStyle: .stamp)
                .accessibilityIdentifier("restDayPoliceResult")

            notificationCard
            manualFallbackCard

            Button(action: reset) {
                Label("Reset the docket", systemImage: "arrow.counterclockwise")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .accessibilityIdentifier("resetRestDayPoliceButton")
        }
        .onAppear {
            loadNudgeDate()
            if healthConnected && !manualMode { importHealthWorkouts() }
            if manualMode {
                manualEditorVisible = true
                healthStatus = "Manual streak active. Apple Health remains optional."
            }
        }
        .onChange(of: dailyNudgeEnabled) { _, enabled in
            if enabled {
                scheduleDailyNudge()
            } else {
                DumbLocalNotifications.cancel(identifier: Self.notificationIdentifier)
                notificationMessage = "Off. The officers will not visit your lock screen."
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
        DumbCard(accent: accent, isSelected: healthStreak != nil) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.title2.weight(.black))
                        .foregroundStyle(accent)
                        .frame(width: 54, height: 54)
                        .background(accent.opacity(0.14), in: Circle())
                    VStack(alignment: .leading, spacing: 3) {
                        Text(healthStreak == nil ? "OPTIONAL ACTIVITY LOG" : "ACTIVITY LOG RECEIVED")
                            .font(.caption2.weight(.black))
                            .tracking(1.1)
                            .foregroundStyle(accent)
                        Text(healthStreak == nil ? "Let the watch build the case." : "Recent activity is in evidence.")
                            .font(.headline.weight(.black))
                            .foregroundStyle(CorpPalette.ink)
                    }
                }

                Button(action: importHealthWorkouts) {
                    Label(
                        isLoadingHealth ? "Checking Apple Health…" : healthStreak == nil ? "Connect Apple Health" : "Refresh activity log",
                        systemImage: isLoadingHealth ? "hourglass" : "heart.text.square.fill"
                    )
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
                }
                .foregroundStyle(accent)
                .buttonStyle(DumbPressStyle())
                .disabled(isLoadingHealth)
                .accessibilityIdentifier("importRestDayHealthButton")

                Text(healthStreak == nil ? healthStatus : "Read-only: consecutive days with Apple Health workout entries in the recent window.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("restDayPoliceHealthCard")
    }

    private var streakCard: some View {
        DumbCard(accent: accent, isSelected: effectiveStreak > 5) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(accent.opacity(0.13))
                        .frame(width: 82, height: 82)
                    Text("\(effectiveStreak)")
                        .font(.system(.largeTitle, design: .rounded).weight(.black))
                        .foregroundStyle(accent)
                }
                VStack(alignment: .leading, spacing: 5) {
                    Text(healthStreak == nil ? "MANUAL DOSSIER" : "ACTIVITY DOSSIER")
                        .font(.caption2.weight(.black))
                        .tracking(1.1)
                        .foregroundStyle(accent)
                    Text("days in a row")
                        .font(.title3.weight(.black))
                        .foregroundStyle(CorpPalette.ink)
                    Text(effectiveStreak > 5 ? "The paperwork is becoming suspicious." : "No excessive-consistency citation yet.")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CorpPalette.mutedInk)
                }
                Spacer(minLength: 0)
            }
        }
        .accessibilityIdentifier("restDayPoliceInput")
        .accessibilityElement(children: .combine)
        .accessibilityValue("\(effectiveStreak) training days in a row")
    }

    private var notificationCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: "bell.badge.fill")
                        .font(.title3.weight(.black))
                        .foregroundStyle(accent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("OFFICER CHECK-IN")
                            .font(.caption2.weight(.black))
                            .tracking(1.1)
                            .foregroundStyle(accent)
                        Text("One optional reminder to review your own docket.")
                            .font(.subheadline.weight(.black))
                            .foregroundStyle(CorpPalette.ink)
                    }
                }
                Toggle("Remind me to check in", isOn: $dailyNudgeEnabled)
                    .font(.subheadline.weight(.black))
                    .tint(accent)
                    .accessibilityIdentifier("restDayPoliceDailyNudgeSwitch")
                DatePicker("Check-in time", selection: $nudgeDate, displayedComponents: .hourAndMinute)
                    .font(.subheadline.weight(.bold))
                    .disabled(!dailyNudgeEnabled)
                    .accessibilityIdentifier("restDayPoliceNudgeTimePicker")
                Text(notificationMessage)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("restDayPoliceNotificationCard")
    }

    private var manualFallbackCard: some View {
        DumbCard(accent: accent) {
            DisclosureGroup(isExpanded: $manualEditorVisible) {
                DumbSlider(
                    title: "Fictional streak: \(Int(streak.rounded())) days",
                    value: $streak,
                    range: 0...21,
                    step: 1,
                    accent: accent
                )
                .padding(.top, 10)
                .disabled(healthStreak != nil)
                .accessibilityIdentifier("restDayPoliceManualSlider")

                if healthStreak != nil {
                    Button("Switch to manual streak") {
                        healthStreak = nil
                        manualMode = true
                        manualEditorVisible = true
                        healthStatus = "Manual streak active. Apple Health remains optional."
                    }
                    .font(.caption.weight(.black))
                    .foregroundStyle(accent)
                    .buttonStyle(DumbPressStyle())
                } else {
                    Text("Manual mode is the backup for simulator use, no data, or a fictional case.")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } label: {
                Label("Enter a fictional streak", systemImage: "slider.horizontal.3")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(CorpPalette.ink)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("restDayPoliceManualCard")
    }

    private func issueCitation() {
        result = effectiveStreak > 5
            ? "CITATION: Excessive consistency. Fictional sentence: consider a guilt-free pause if that suits you."
            : "No citation. The fictional officers find no excessive-consistency paperwork."
    }

    private func reset() {
        streak = 6
        result = "No training record. No officers dispatched."
        healthStreak = nil
        healthStatus = "Apple Health is optional. You can enter a fictional streak."
        manualMode = false
        manualEditorVisible = false
        dailyNudgeEnabled = false
        DumbLocalNotifications.cancel(identifier: Self.notificationIdentifier)
        notificationMessage = "Off. The officers will not visit your lock screen."
    }

    private func importHealthWorkouts() {
        manualMode = false

        guard HKHealthStore.isHealthDataAvailable() else {
            manualEditorVisible = true
            healthStatus = "Apple Health is unavailable here. Enter a fictional streak below."
            return
        }

        isLoadingHealth = true
        healthStore.requestAuthorization(toShare: [], read: [workoutType]) { success, error in
            guard success, error == nil else {
                DispatchQueue.main.async {
                    isLoadingHealth = false
                    manualEditorVisible = true
                    healthStatus = "Apple Health wasn’t shared. Enter a fictional streak below."
                }
                return
            }

            let calendar = Calendar.autoupdatingCurrent
            let today = calendar.startOfDay(for: Date())
            let start = calendar.date(byAdding: .day, value: -14, to: today) ?? today
            let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)
            let query = HKSampleQuery(
                sampleType: workoutType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                guard error == nil else {
                    DispatchQueue.main.async {
                        isLoadingHealth = false
                        manualEditorVisible = true
                        healthStatus = "Apple Health could not be read right now. Enter a fictional streak below."
                    }
                    return
                }

                let activeDays = Set((samples as? [HKWorkout] ?? []).map { calendar.startOfDay(for: $0.startDate) })
                var cursor = today
                if !activeDays.contains(cursor) {
                    cursor = calendar.date(byAdding: .day, value: -1, to: cursor) ?? cursor
                }
                var consecutiveDays = 0
                while activeDays.contains(cursor) {
                    consecutiveDays += 1
                    cursor = calendar.date(byAdding: .day, value: -1, to: cursor) ?? cursor
                }

                DispatchQueue.main.async {
                    isLoadingHealth = false
                    healthStreak = consecutiveDays
                    healthConnected = true
                    healthStatus = consecutiveDays > 0
                        ? "Using recent read-only workout entries from Apple Health."
                        : "No recent workout entries arrived. Enter a fictional streak below."
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
        notificationMessage = "Asking for permission, then scheduling one quiet-hours-aware officer check-in."
        Task {
            let outcome = await DumbLocalNotifications.scheduleDaily(
                identifier: Self.notificationIdentifier,
                title: "Rest Day Police check-in",
                body: "Your private activity docket is waiting for a tiny review.",
                proposedTime: date
            )
            await MainActor.run {
                switch outcome {
                case .scheduled(let scheduledDate):
                    notificationMessage = "One officer check-in scheduled for \(scheduledDate.formatted(date: .omitted, time: .shortened))."
                case .denied:
                    dailyNudgeEnabled = false
                    notificationMessage = "Notifications are off in Settings. The docket still works without them."
                case .failed:
                    dailyNudgeEnabled = false
                    notificationMessage = "The officer reminder did not stick. The docket still works without it."
                }
            }
        }
    }
}
