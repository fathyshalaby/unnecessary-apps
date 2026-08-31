import HealthKit
import SwiftUI
import DumbKit

@main
struct SleepAlibiApp: App {
    var body: some Scene {
        WindowGroup { SleepAlibiView().dumbNativeEntry(scheme: "app37sleepalibi") { _, _ in } }
    }
}

struct SleepAlibiView: View {
    @AppStorage("sleepAlibi.hours") private var hours = 5.5
    @AppStorage("sleepAlibi.result") private var alibi = "The witness has not testified."
    @AppStorage("sleepAlibi.healthConnected") private var healthConnected = false
    @AppStorage("sleepAlibi.manualMode") private var manualMode = false
    @AppStorage("sleepAlibi.dailyNudgeEnabled") private var dailyNudgeEnabled = false
    @AppStorage("sleepAlibi.nudgeHour") private var nudgeHour = 9
    @AppStorage("sleepAlibi.nudgeMinute") private var nudgeMinute = 30

    @State private var healthSleepHours: Double?
    @State private var healthStatus = "Apple Health is optional. Tap once to use recent sleep evidence."
    @State private var isLoadingHealth = false
    @State private var manualEditorVisible = false
    @State private var notificationMessage = "Off. The courtroom opens whenever you choose."
    @State private var nudgeDate = Date()
    @State private var didLoadNudgeDate = false

    private let accent = CorpPalette.sleepyLavender
    private let healthStore = HKHealthStore()
    private static let notificationIdentifier = "sleep-alibi.daily-check-in"

    private var sleepType: HKCategoryType? {
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
    }

    private var effectiveHours: Double {
        healthSleepHours ?? hours
    }

    var body: some View {
        AppCanvas(accent: accent, experience: .wellness) {
            AppHeader(
                eyebrow: "REST DEFENSE COUNSEL",
                title: "Sleep alibi",
                subtitle: "A tiny courtroom for the morning after.",
                accent: accent
            )

            DumbHeroMeter(
                progress: min(effectiveHours / 9, 1),
                valueLabel: String(format: "%.1f hr", effectiveHours),
                title: "Sleep evidence",
                subtitle: effectiveHours < 4 ? "Extremely dramatic testimony" : effectiveHours < 7 ? "Complicated case" : "Respectable alibi",
                accent: accent,
                systemImage: "moon.zzz.fill",
                variant: .arc
            )
            .accessibilityIdentifier("sleepAlibiHeroMeter")

            DumbBoundaryChip(
                storageKey: "sleepAlibi.boundaryDismissed",
                message: "Duration reflection only—not a sleep score or medical advice.",
                accent: accent,
                systemImage: "moon.fill"
            )

            healthConnectionCard
            evidenceCard

            notificationCard
            manualFallbackCard

            Button(action: reset) {
            Label("Reset the testimony", systemImage: "arrow.counterclockwise")
            .font(.subheadline.weight(.black))
            .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .accessibilityIdentifier("resetSleepAlibiButton")

        } bottomBar: {
            DumbAction(
            title: "Present my alibi",
            accent: accent,
            systemImage: "building.columns.fill",
            action: generateAlibi
            )
            .accessibilityIdentifier("generateSleepAlibiButton")

            DumbResult(text: alibi, accent: accent, systemImage: "quote.bubble.fill", reactionStyle: .stamp)
            .accessibilityIdentifier("sleepAlibiResult")

            if alibi != "The witness has not testified." && !alibi.hasPrefix("Sleep evidence changed") {
                DumbShareVerdict(
                    text: alibi,
                    subject: "Sleep alibi",
                    accent: accent,
                    accessibilityIdentifier: "shareSleepAlibiButton"
                )
            }

        }
        .onAppear {
            loadNudgeDate()
            if healthConnected && !manualMode { importHealthSleep() }
            if manualMode {
                manualEditorVisible = true
                healthStatus = "Manual estimate active. Apple Health remains optional."
            }
        }
        .onChange(of: dailyNudgeEnabled) { _, enabled in
            if enabled {
                scheduleDailyNudge()
            } else {
                DumbLocalNotifications.cancel(identifier: Self.notificationIdentifier)
                notificationMessage = "Off. The courtroom opens whenever you choose."
            }
        }
        .onChange(of: nudgeDate) { _, date in
            guard didLoadNudgeDate else { return }
            let calendar = Calendar.autoupdatingCurrent
            nudgeHour = calendar.component(.hour, from: date)
            nudgeMinute = calendar.component(.minute, from: date)
            if dailyNudgeEnabled { scheduleDailyNudge() }
        }
        .onChange(of: hours) { _, _ in invalidateAlibi() }
        .onChange(of: healthSleepHours) { _, _ in invalidateAlibi() }
    }

    private func invalidateAlibi() {
        guard alibi != "The witness has not testified." else { return }
        alibi = "Sleep evidence changed. Present a fresh alibi."
    }

    private var healthConnectionCard: some View {
        DumbCard(accent: accent, isSelected: healthSleepHours != nil) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.title2.weight(.black))
                        .foregroundStyle(accent)
                        .frame(width: 54, height: 54)
                        .background(accent.opacity(0.14), in: Circle())
                    VStack(alignment: .leading, spacing: 3) {
                        Text(healthSleepHours == nil ? "APPLE HEALTH EVIDENCE" : "EVIDENCE RECEIVED")
                            .font(.caption2.weight(.black))
                            .tracking(1.1)
                            .foregroundStyle(accent)
                        Text(healthSleepHours == nil ? "Let the phone testify." : "Last sleep window imported.")
                            .font(.headline.weight(.black))
                            .foregroundStyle(CorpPalette.ink)
                    }
                }

                Button(action: importHealthSleep) {
                    Label(
                        isLoadingHealth ? "Checking Apple Health…" : healthSleepHours == nil ? "Use Apple Health sleep" : "Refresh sleep evidence",
                        systemImage: isLoadingHealth ? "hourglass" : "heart.text.square.fill"
                    )
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
                }
                .foregroundStyle(accent)
                .buttonStyle(DumbPressStyle())
                .disabled(isLoadingHealth)
                .accessibilityIdentifier("importHealthSleepButton")

                Text(healthSleepHours == nil ? healthStatus : "Read-only and used only to draft this playful alibi.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("sleepAlibiHealthCard")
    }

    private var evidenceCard: some View {
        DumbCard(accent: accent, isSelected: effectiveHours >= 7) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(healthSleepHours == nil ? "MANUAL TESTIMONY" : "SLEEP EVIDENCE")
                            .font(.caption2.weight(.black))
                            .tracking(1.1)
                            .foregroundStyle(accent)
                        Text(String(format: "%.1f hours", effectiveHours))
                            .font(.system(.largeTitle, design: .rounded).weight(.black))
                            .foregroundStyle(CorpPalette.ink)
                    }
                    Spacer()
                    Image(systemName: effectiveHours >= 7 ? "checkmark.seal.fill" : "exclamationmark.bubble.fill")
                        .font(.title2.weight(.black))
                        .foregroundStyle(accent)
                }
                Text(effectiveHours < 4 ? "The evidence is extremely dramatic." : effectiveHours < 7 ? "The evidence is… complicated." : "The evidence is surprisingly respectable.")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CorpPalette.mutedInk)
                Text("Duration only—not a sleep score, diagnosis, or recommendation.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
            }
        }
        .accessibilityIdentifier("sleepAlibiEvidenceCard")
    }

    private var notificationCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: "bell.badge.fill")
                        .font(.title3.weight(.black))
                        .foregroundStyle(accent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("MORNING COURTROOM")
                            .font(.caption2.weight(.black))
                            .tracking(1.1)
                            .foregroundStyle(accent)
                        Text("One optional opening bell for your alibi.")
                            .font(.subheadline.weight(.black))
                            .foregroundStyle(CorpPalette.ink)
                    }
                }
                Toggle("Remind me to check in", isOn: $dailyNudgeEnabled)
                    .font(.subheadline.weight(.black))
                    .tint(accent)
                    .accessibilityIdentifier("sleepAlibiDailyNudgeSwitch")
                DatePicker("Opening time", selection: $nudgeDate, displayedComponents: .hourAndMinute)
                    .font(.subheadline.weight(.bold))
                    .disabled(!dailyNudgeEnabled)
                    .accessibilityIdentifier("sleepAlibiNudgeTimePicker")
                Text(notificationMessage)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("sleepAlibiNotificationCard")
    }

    private var manualFallbackCard: some View {
        DumbCard(accent: accent) {
            DisclosureGroup(isExpanded: $manualEditorVisible) {
                DumbSlider(
                    title: "Manual hours: \(String(format: "%.1f", hours))",
                    value: $hours,
                    range: 0...12,
                    step: 0.5,
                    accent: accent
                )
                .padding(.top, 10)
                .disabled(healthSleepHours != nil)
                .accessibilityIdentifier("sleepAlibiManualSlider")

                if healthSleepHours != nil {
                    Button("Switch to manual estimate") {
                        healthSleepHours = nil
                        manualMode = true
                        manualEditorVisible = true
                        healthStatus = "Manual estimate active. Apple Health remains optional."
                    }
                    .font(.caption.weight(.black))
                    .foregroundStyle(accent)
                    .buttonStyle(DumbPressStyle())
                } else {
                    Text("Manual mode remains available when the phone has no sleep evidence or you prefer your own estimate.")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } label: {
                Label("Enter a manual estimate", systemImage: "slider.horizontal.3")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(CorpPalette.ink)
            }
        }
        .accessibilityIdentifier("sleepAlibiInput")
    }

    private func generateAlibi() {
        alibi = effectiveHours < 4
            ? "Your honor, the defendant was awake for most of the night and has no further questions."
            : effectiveHours < 7
                ? "The defendant slept, but not in a way that inspires confidence."
                : "The defense has no case. You slept adequately."
    }

    private func reset() {
        hours = 5.5
        alibi = "The witness has not testified."
        healthSleepHours = nil
        healthStatus = "Apple Health is optional. Tap once to use recent sleep evidence."
        manualMode = false
        manualEditorVisible = false
        dailyNudgeEnabled = false
        DumbLocalNotifications.cancel(identifier: Self.notificationIdentifier)
        notificationMessage = "Off. The courtroom opens whenever you choose."
    }

    private func importHealthSleep() {
        manualMode = false

        guard let sleepType else {
            manualEditorVisible = true
            healthStatus = "Apple Health is unavailable here. Enter sleep manually below."
            return
        }
        guard HKHealthStore.isHealthDataAvailable() else {
            manualEditorVisible = true
            healthStatus = "Apple Health is unavailable here. Enter sleep manually below."
            return
        }

        isLoadingHealth = true
        healthStore.requestAuthorization(toShare: [], read: [sleepType]) { success, error in
            guard success, error == nil else {
                DispatchQueue.main.async {
                    isLoadingHealth = false
                    manualEditorVisible = true
                    healthStatus = "Apple Health wasn’t shared. Enter sleep manually below."
                }
                return
            }

            let end = Date()
            let start = Calendar.autoupdatingCurrent.date(byAdding: .hour, value: -36, to: end) ?? end.addingTimeInterval(-129_600)
            let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sort]
            ) { _, samples, error in
                guard error == nil else {
                    DispatchQueue.main.async {
                        healthSleepHours = nil
                        isLoadingHealth = false
                        manualEditorVisible = true
                        healthStatus = "Apple Health could not be read right now. Enter sleep manually below."
                    }
                    return
                }

                let asleepSamples = (samples as? [HKCategorySample] ?? []).filter { Self.isAsleep($0.value) }
                let seconds = Self.mergedAsleepDuration(asleepSamples)
                let sleepHours = seconds / 3_600

                DispatchQueue.main.async {
                    isLoadingHealth = false
                    if sleepHours > 0 {
                        healthSleepHours = sleepHours
                        healthConnected = true
                        healthStatus = "Using recent read-only sleep samples from Apple Health."
                    } else {
                        healthSleepHours = nil
                        healthConnected = true
                        manualEditorVisible = true
                        healthStatus = "No sleep arrived from Apple Health. Enter it manually below."
                    }
                }
            }
            healthStore.execute(query)
        }
    }

    private static func isAsleep(_ value: Int) -> Bool {
        [
            HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
            HKCategoryValueSleepAnalysis.asleepCore.rawValue,
            HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
            HKCategoryValueSleepAnalysis.asleepREM.rawValue
        ].contains(value)
    }

    private static func mergedAsleepDuration(_ samples: [HKCategorySample]) -> TimeInterval {
        let intervals = samples
            .map { (start: $0.startDate, end: $0.endDate) }
            .filter { $0.end > $0.start }
            .sorted { $0.start < $1.start }
        guard var current = intervals.first else { return 0 }

        var total: TimeInterval = 0
        for interval in intervals.dropFirst() {
            if interval.start <= current.end {
                current.end = max(current.end, interval.end)
            } else {
                total += current.end.timeIntervalSince(current.start)
                current = interval
            }
        }
        return total + current.end.timeIntervalSince(current.start)
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
        notificationMessage = "Asking for permission, then scheduling one quiet-hours-aware opening bell."
        Task {
            let outcome = await DumbLocalNotifications.scheduleDaily(
                identifier: Self.notificationIdentifier,
                title: "Sleep Alibi courtroom",
                body: "Your morning alibi desk is open whenever you want to check in.",
                proposedTime: date
            )
            await MainActor.run {
                switch outcome {
                case .scheduled(let scheduledDate):
                    notificationMessage = "One opening bell scheduled for \(scheduledDate.formatted(date: .omitted, time: .shortened))."
                case .denied:
                    dailyNudgeEnabled = false
                    notificationMessage = "Notifications are off in Settings. The alibi still works without them."
                case .failed:
                    dailyNudgeEnabled = false
                    notificationMessage = "The opening bell did not stick. The alibi still works without it."
                }
            }
        }
    }
}
