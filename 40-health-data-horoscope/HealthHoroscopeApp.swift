import HealthKit
import SwiftUI
import DumbKit

@main
struct HealthHoroscopeApp: App {
    var body: some Scene {
        WindowGroup { HealthHoroscopeView().dumbNativeEntry(scheme: "app40healthhoroscope") { _, _ in } }
    }
}

struct HealthHoroscopeView: View {
    @AppStorage("healthHoroscope.steps") private var steps = 5000.0
    @AppStorage("healthHoroscope.sleep") private var sleep = 7.0
    @AppStorage("healthHoroscope.result") private var result = "The stars are waiting for numbers."
    @AppStorage("healthHoroscope.healthConnected") private var healthConnected = false
    @AppStorage("healthHoroscope.manualMode") private var manualMode = false
    @AppStorage("healthHoroscope.dailyNudgeEnabled") private var dailyNudgeEnabled = false
    @AppStorage("healthHoroscope.nudgeHour") private var nudgeHour = 8
    @AppStorage("healthHoroscope.nudgeMinute") private var nudgeMinute = 0

    @State private var healthSteps: Double?
    @State private var healthSleepHours: Double?
    @State private var healthStatus = "Apple Health is optional. The planets can accept manual numbers."
    @State private var isLoadingHealth = false
    @State private var manualEditorVisible = false
    @State private var notificationMessage = "Off. The constellation does not chase anyone."
    @State private var nudgeDate = Date()
    @State private var didLoadNudgeDate = false

    private let accent = CorpPalette.violet
    private let healthStore = HKHealthStore()
    private static let notificationIdentifier = "health-horoscope.daily-check-in"

    private var stepType: HKQuantityType? {
        HKObjectType.quantityType(forIdentifier: .stepCount)
    }

    private var sleepType: HKCategoryType? {
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
    }

    private var effectiveSteps: Double {
        healthSteps ?? steps
    }

    private var effectiveSleep: Double {
        healthSleepHours ?? sleep
    }

    var body: some View {
        AppCanvas(accent: accent, experience: .oracle) {
            AppHeader(
                eyebrow: "TOTALLY FICTIONAL WELLNESS ASTROLOGY",
                title: "Health data horoscope",
                subtitle: "Your numbers get a constellation. The planets stay out of medicine.",
                accent: accent
            )

            disclaimerCard

            DumbBoundaryChip(
                storageKey: "healthHoroscope.boundaryDismissed",
                message: "Fictional horoscope only—not medical, wellness, or predictive advice.",
                accent: accent,
                systemImage: "moon.stars.fill"
            )

            DumbHeroMeter(
                progress: min((effectiveSteps / 8000 + effectiveSleep / 8) / 2, 1),
                valueLabel: "Cosmic load",
                title: "Constellation input",
                subtitle: "\(Int(effectiveSteps.rounded())) steps · \(String(format: "%.1f", effectiveSleep)) hr sleep",
                accent: accent,
                systemImage: "sparkles",
                variant: .arc
            )
            .accessibilityIdentifier("healthHoroscopeHeroMeter")

            healthConnectionCard
            cosmicReadoutCard

            notificationCard
            manualInputsCard

            Button(action: reset) {
            Label("Reset the constellation", systemImage: "arrow.counterclockwise")
            .font(.subheadline.weight(.black))
            .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .accessibilityIdentifier("resetHealthHoroscopeButton")

        } bottomBar: {
            DumbAction(
            title: "Consult the planets",
            accent: accent,
            systemImage: "sparkles",
            action: consultPlanets
            )
            .accessibilityIdentifier("consultHealthHoroscopeButton")

            DumbResult(text: result, accent: accent, systemImage: "moon.stars.fill", reactionStyle: .bounce)
            .accessibilityIdentifier("healthHoroscopeResult")

            if result != "The stars are waiting for numbers." && !result.hasPrefix("The numbers shifted") {
                DumbShareVerdict(
                    text: result,
                    subject: "Health horoscope",
                    accent: accent,
                    accessibilityIdentifier: "shareHealthHoroscopeButton"
                )
            }

        }
        .onAppear {
            loadNudgeDate()
            if healthConnected && !manualMode { importHealthData() }
            if manualMode {
                manualEditorVisible = true
                healthStatus = "Manual numbers active. Apple Health remains optional."
            }
        }
        .onChange(of: dailyNudgeEnabled) { _, enabled in
            if enabled {
                scheduleDailyNudge()
            } else {
                DumbLocalNotifications.cancel(identifier: Self.notificationIdentifier)
                notificationMessage = "Off. The constellation does not chase anyone."
            }
        }
        .onChange(of: nudgeDate) { _, date in
            guard didLoadNudgeDate else { return }
            let calendar = Calendar.autoupdatingCurrent
            nudgeHour = calendar.component(.hour, from: date)
            nudgeMinute = calendar.component(.minute, from: date)
            if dailyNudgeEnabled { scheduleDailyNudge() }
        }
        .onChange(of: steps) { _, _ in invalidateOracle() }
        .onChange(of: sleep) { _, _ in invalidateOracle() }
        .onChange(of: healthSteps) { _, _ in invalidateOracle() }
        .onChange(of: healthSleepHours) { _, _ in invalidateOracle() }
    }

    private func invalidateOracle() {
        guard result != "The stars are waiting for numbers." else { return }
        result = "The numbers shifted. Consult the planets again."
    }

    private var disclaimerCard: some View {
        DumbCard(accent: accent) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.title3.weight(.black))
                    .foregroundStyle(accent)
                VStack(alignment: .leading, spacing: 4) {
                    Text("ENTERTAINMENT ONLY")
                        .font(.caption2.weight(.black))
                        .tracking(1.1)
                        .foregroundStyle(accent)
                    Text("This is a joke generator. It does not interpret health data, predict outcomes, or recommend treatment.")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(CorpPalette.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityIdentifier("healthHoroscopeDisclaimer")
    }

    private var healthConnectionCard: some View {
        DumbCard(accent: accent, isSelected: healthSteps != nil || healthSleepHours != nil) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.title2.weight(.black))
                        .foregroundStyle(accent)
                        .frame(width: 54, height: 54)
                        .background(accent.opacity(0.14), in: Circle())
                    VStack(alignment: .leading, spacing: 3) {
                        Text(healthSteps == nil && healthSleepHours == nil ? "OPTIONAL HEALTH DATA" : "HEALTH DATA RECEIVED")
                            .font(.caption2.weight(.black))
                            .tracking(1.1)
                            .foregroundStyle(accent)
                        Text(healthSteps == nil && healthSleepHours == nil ? "Let the phone feed the stars." : "Two tiny facts, zero prophecies.")
                            .font(.headline.weight(.black))
                            .foregroundStyle(CorpPalette.ink)
                    }
                }

                Button(action: importHealthData) {
                    Label(
                        isLoadingHealth ? "Checking Apple Health…" : healthSteps == nil && healthSleepHours == nil ? "Connect Apple Health" : "Refresh Apple Health",
                        systemImage: isLoadingHealth ? "hourglass" : "heart.text.square.fill"
                    )
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
                }
                .foregroundStyle(accent)
                .buttonStyle(DumbPressStyle())
                .disabled(isLoadingHealth)
                .accessibilityIdentifier("connectHealthHoroscopeButton")

                Text(healthSteps == nil && healthSleepHours == nil ? healthStatus : "Read-only steps and sleep are used to generate entertainment only.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("healthHoroscopeHealthCard")
    }

    private var cosmicReadoutCard: some View {
        DumbCard(accent: accent, isSelected: effectiveSteps > 9000 && effectiveSleep > 7) {
            VStack(alignment: .leading, spacing: 9) {
                HStack(alignment: .firstTextBaseline) {
                    Text("TODAY’S COSMIC INPUT")
                        .font(.caption2.weight(.black))
                        .tracking(1.1)
                        .foregroundStyle(accent)
                    Spacer()
                    Image(systemName: "moon.stars.fill")
                        .foregroundStyle(accent)
                }
                HStack(spacing: 12) {
                    metric(
                        title: "STEPS",
                        value: "\(Int(effectiveSteps.rounded()))",
                        icon: "figure.walk",
                        source: healthSteps != nil ? "Apple Health" : "Manual"
                    )
                    metric(
                        title: "SLEEP",
                        value: String(format: "%.1fh", effectiveSleep),
                        icon: "bed.double.fill",
                        source: healthSleepHours != nil ? "Apple Health" : "Manual"
                    )
                }
                Text(healthSteps == nil && healthSleepHours == nil ? "Manual numbers are fine. No health claim is hiding behind the glitter." : "Imported values are shown as supplied; incomplete data is possible.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
            }
        }
        .accessibilityIdentifier("healthHoroscopeInputs")
    }

    private func metric(title: String, value: String, icon: String, source: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(accent)
                Spacer()
                DumbStatusPill(source.uppercased(), systemImage: source == "Apple Health" ? "heart.text.square.fill" : "hand.raised.fill", accent: accent)
            }
            Text(title)
                .font(.caption2.weight(.black))
                .tracking(0.9)
                .foregroundStyle(CorpPalette.mutedInk)
            Text(value)
                .font(.title3.weight(.black))
                .foregroundStyle(CorpPalette.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var notificationCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: "bell.badge.fill")
                        .font(.title3.weight(.black))
                        .foregroundStyle(accent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("DAILY CONSTELLATION")
                            .font(.caption2.weight(.black))
                            .tracking(1.1)
                            .foregroundStyle(accent)
                        Text("One optional bit of cosmic nonsense.")
                            .font(.subheadline.weight(.black))
                            .foregroundStyle(CorpPalette.ink)
                    }
                }
                Toggle("Remind me to consult", isOn: $dailyNudgeEnabled)
                    .font(.subheadline.weight(.black))
                    .tint(accent)
                    .accessibilityIdentifier("healthHoroscopeDailyNudgeSwitch")
                DatePicker("Constellation time", selection: $nudgeDate, displayedComponents: .hourAndMinute)
                    .font(.subheadline.weight(.bold))
                    .disabled(!dailyNudgeEnabled)
                    .accessibilityIdentifier("healthHoroscopeNudgeTimePicker")
                Text(notificationMessage)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("healthHoroscopeNotificationCard")
    }

    private var manualInputsCard: some View {
        DumbCard(accent: accent) {
            DisclosureGroup(isExpanded: $manualEditorVisible) {
                VStack(alignment: .leading, spacing: 10) {
                    DumbSlider(title: "Manual steps: \(Int(steps.rounded()))", value: $steps, range: 0...20000, step: 100, accent: accent)
                        .disabled(healthSteps != nil)
                    DumbSlider(title: "Manual sleep: \(String(format: "%.1f", sleep)) hours", value: $sleep, range: 0...12, step: 0.5, accent: accent)
                        .disabled(healthSleepHours != nil)

                    if healthSteps != nil || healthSleepHours != nil {
                        Button("Switch to manual numbers") {
                            healthSteps = nil
                            healthSleepHours = nil
                            manualMode = true
                            manualEditorVisible = true
                            healthStatus = "Manual numbers active. Apple Health remains optional."
                        }
                        .font(.caption.weight(.black))
                        .foregroundStyle(accent)
                        .buttonStyle(DumbPressStyle())
                    } else {
                        Text("Manual numbers are the fallback when HealthKit is unavailable or you want the joke to use your own inputs.")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CorpPalette.mutedInk)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.top, 10)
            } label: {
                Label("Use manual numbers", systemImage: "slider.horizontal.3")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(CorpPalette.ink)
            }
        }
        .accessibilityIdentifier("healthHoroscopeManualInputs")
    }

    private func consultPlanets() {
        result = effectiveSteps > 9000 && effectiveSleep > 7
            ? "Today you are a Responsible Moon. People may ask you for advice. This is not evidence."
            : effectiveSteps < 3000
                ? "Mercury is in retrograde and the spreadsheet says ‘kitchen moon.’ Pure theatre, no prescription."
                : "Your constellation is Mildly Functional. Protect your snacks and distrust the horoscope."
    }

    private func reset() {
        steps = 5000
        sleep = 7
        result = "The stars are waiting for numbers."
        healthSteps = nil
        healthSleepHours = nil
        healthStatus = "Apple Health is optional. The planets can accept manual numbers."
        manualMode = false
        manualEditorVisible = false
        dailyNudgeEnabled = false
        DumbLocalNotifications.cancel(identifier: Self.notificationIdentifier)
        notificationMessage = "Off. The constellation does not chase anyone."
    }

    private func importHealthData() {
        manualMode = false

        guard let stepType, let sleepType else {
            manualEditorVisible = true
            healthStatus = "Apple Health is unavailable here. Manual numbers are ready below."
            return
        }
        guard HKHealthStore.isHealthDataAvailable() else {
            manualEditorVisible = true
            healthStatus = "Apple Health is unavailable here. Manual numbers are ready below."
            return
        }

        isLoadingHealth = true
        healthStore.requestAuthorization(toShare: [], read: [stepType, sleepType]) { success, error in
            guard success, error == nil else {
                DispatchQueue.main.async {
                    isLoadingHealth = false
                    manualEditorVisible = true
                    healthStatus = "Apple Health wasn’t shared. Manual numbers are ready below."
                }
                return
            }
            readStepData(stepType: stepType, sleepType: sleepType)
        }
    }

    private func readStepData(stepType: HKQuantityType, sleepType: HKCategoryType) {
        let calendar = Calendar.autoupdatingCurrent
        let now = Date()
        let today = calendar.startOfDay(for: now)
        let stepPredicate = HKQuery.predicateForSamples(withStart: today, end: now, options: .strictStartDate)
        let stepQuery = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: stepPredicate,
            options: .cumulativeSum
        ) { _, statistics, _ in
            let importedSteps = statistics?.sumQuantity()?.doubleValue(for: .count()) ?? 0
            let sleepEnd = now
            let sleepStart = calendar.date(byAdding: .hour, value: -36, to: sleepEnd) ?? sleepEnd.addingTimeInterval(-129_600)
            let sleepPredicate = HKQuery.predicateForSamples(withStart: sleepStart, end: sleepEnd, options: .strictStartDate)
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
            let sleepQuery = HKSampleQuery(
                sampleType: sleepType,
                predicate: sleepPredicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                let asleep = (samples as? [HKCategorySample] ?? []).filter { Self.isAsleep($0.value) }
                let sleepHours = Self.mergedAsleepDuration(asleep) / 3_600
                DispatchQueue.main.async {
                    isLoadingHealth = false
                    healthSteps = importedSteps > 0 ? importedSteps : nil
                    healthSleepHours = sleepHours > 0 ? sleepHours : nil
                    healthConnected = true
                    if healthSteps == nil && healthSleepHours == nil {
                        manualEditorVisible = true
                        healthStatus = "No steps or sleep arrived from Apple Health. Manual numbers are ready below."
                    } else {
                        healthStatus = "Using read-only Apple Health values for entertainment only."
                    }
                }
            }
            healthStore.execute(sleepQuery)
        }
        healthStore.execute(stepQuery)
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
        notificationMessage = "Asking for permission, then scheduling one quiet-hours-aware constellation."
        Task {
            let outcome = await DumbLocalNotifications.scheduleDaily(
                identifier: Self.notificationIdentifier,
                title: "Your fictional constellation",
                body: "The stars have prepared a tiny bit of nonsense whenever you want it.",
                proposedTime: date
            )
            await MainActor.run {
                switch outcome {
                case .scheduled(let scheduledDate):
                    notificationMessage = "One constellation scheduled for \(scheduledDate.formatted(date: .omitted, time: .shortened))."
                case .denied:
                    dailyNudgeEnabled = false
                    notificationMessage = "Notifications are off in Settings. The horoscope still works without them."
                case .failed:
                    dailyNudgeEnabled = false
                    notificationMessage = "The constellation did not stick. The horoscope still works without it."
                }
            }
        }
    }
}
