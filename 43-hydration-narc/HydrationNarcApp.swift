import HealthKit
import SwiftUI
import DumbKit

private struct HydrationDay: Codable, Identifiable {
    var id: String { dayKey }
    let dayKey: String
    let servings: Int
    let goal: Int
}

@main
struct HydrationNarcApp: App {
    var body: some Scene {
        WindowGroup { HydrationNarcView() }
    }
}

struct HydrationNarcView: View {
    private static let emptyResult = "The bottle has not yet contacted management."

    @AppStorage("hydrationNarc.glasses") private var servings = 0.0
    @AppStorage("hydrationNarc.goal") private var goal = 8.0
    @AppStorage("hydrationNarc.day") private var recordedDay = ""
    @AppStorage("hydrationNarc.result") private var storedResult = Self.emptyResult
    @AppStorage("hydrationNarc.history") private var storedHistory = "[]"
    @AppStorage("hydrationNarc.healthConnected") private var healthConnected = false
    @AppStorage("hydrationNarc.dailyNudgeEnabled") private var dailyNudgeEnabled = false
    @AppStorage("hydrationNarc.nudgeHour") private var nudgeHour = 14
    @AppStorage("hydrationNarc.nudgeMinute") private var nudgeMinute = 0

    @State private var result = Self.emptyResult
    @State private var history: [HydrationDay] = []
    @State private var hasLoaded = false
    @State private var showResetConfirmation = false
    @State private var healthWaterMilliliters: Double?
    @State private var healthStatus = "Apple Health is optional. The manual serving ledger works on its own."
    @State private var isLoadingHealth = false
    @State private var notificationMessage = "Off. The bottle will not send a collection agency."
    @State private var nudgeDate = Date()
    @State private var didLoadNudgeDate = false

    private let accent = CorpPalette.bathroomBlue
    private let healthStore = HKHealthStore()
    private static let notificationIdentifier = "hydration-narc.daily-check-in"

    private var waterType: HKQuantityType? {
        HKObjectType.quantityType(forIdentifier: .dietaryWater)
    }

    var body: some View {
        DumbShell(
            eyebrow: "BOTTLE OVERSIGHT",
            title: "Hydration narc",
            subtitle: "A manual one-tap water ledger. The bottle reacts when you log—not from proactive notifications.",
            accent: accent,
            personality: .office,
            experience: .wellness
        ) {
            progressCard

            DumbSlider(
                title: "Your daily serving goal: \(Int(goal.rounded()))",
                value: $goal,
                range: 1...16,
                step: 1,
                accent: accent
            )
            .accessibilityIdentifier("hydrationGoalSlider")

            DumbAction(
                title: "Log one serving",
                accent: accent,
                systemImage: "drop.fill",
                action: logOneServing
            )
            .disabled(servings >= 24)
            .accessibilityIdentifier("logGlassButton")

            Button(action: undoOneServing) {
                Label("Undo last serving", systemImage: "minus.circle.fill")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(servings <= 0)
            .accessibilityIdentifier("undoGlassButton")

            DumbResult(
                text: result,
                accent: accent,
                systemImage: "drop.triangle.fill",
                reactionStyle: .bounce
            )
            .accessibilityIdentifier("hydrationResult")

            healthConnectionCard
            notificationCard
            historyCard

            Button {
                showResetConfirmation = true
            } label: {
                Label("Empty today’s ledger", systemImage: "arrow.counterclockwise")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(servings <= 0)
            .accessibilityIdentifier("resetHydrationButton")
            .accessibilityHint("Asks for confirmation before clearing today’s serving count.")

            DumbNativeTip(
                "Siri & Shortcuts",
                detail: "Say “Log water in Hydration Narc” or add the Shortcuts action for a one-tap serving without hunting for the icon.",
                systemImage: "drop.fill",
                accent: accent
            )
        }
        .dumbNativeEntry(scheme: "app43hydrationnarc") { action, _ in
            if action == "log" {
                logOneServing()
            }
        }
        .onAppear {
            loadAndRollDay()
            loadNudgeDate()
            if healthConnected { importHealthWater() }
            syncWidgetSnapshot()
        }
        .onChange(of: servings) { _, _ in syncWidgetSnapshot() }
        .onChange(of: goal) { _, _ in
            syncWidgetSnapshot()
            reportToBottle()
        }
        .onChange(of: dailyNudgeEnabled) { _, enabled in
            if enabled {
                scheduleDailyNudge()
            } else {
                DumbLocalNotifications.cancel(identifier: Self.notificationIdentifier)
                notificationMessage = "Off. The bottle will not send a collection agency."
            }
        }
        .onChange(of: nudgeDate) { _, date in
            guard didLoadNudgeDate else { return }
            let calendar = Calendar.autoupdatingCurrent
            nudgeHour = calendar.component(.hour, from: date)
            nudgeMinute = calendar.component(.minute, from: date)
            if dailyNudgeEnabled { scheduleDailyNudge() }
        }
        .confirmationDialog(
            "Empty today’s water ledger?",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Confirm empty today's ledger", role: .destructive, action: resetToday)
            Button("Keep today's log", role: .cancel) {}
        } message: {
            Text("This keeps earlier daily summaries but removes today's serving count.")
        }
    }

    private var healthConnectionCard: some View {
        DumbCard(accent: accent, isSelected: healthWaterMilliliters != nil) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.title2.weight(.black))
                        .foregroundStyle(accent)
                        .frame(width: 54, height: 54)
                        .background(accent.opacity(0.14), in: Circle())
                    VStack(alignment: .leading, spacing: 3) {
                        Text(healthWaterMilliliters == nil ? "OPTIONAL HEALTH LEDGER" : "HEALTH WATER RECEIVED")
                            .font(.caption2.weight(.black))
                            .tracking(1.1)
                            .foregroundStyle(accent)
                        Text(healthWaterMilliliters == nil ? "Let the phone check the bottle." : "Today’s logged water is here.")
                            .font(.headline.weight(.black))
                            .foregroundStyle(CorpPalette.ink)
                    }
                }

                if let healthWaterMilliliters {
                    Text("\(Int(healthWaterMilliliters.rounded())) mL in Apple Health")
                        .font(.title3.weight(.black))
                        .foregroundStyle(CorpPalette.ink)
                    Text("Shown separately because Health data may be incomplete and a serving means your chosen amount.")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Button(action: importHealthWater) {
                    Label(
                        isLoadingHealth ? "Checking Apple Health…" : healthWaterMilliliters == nil ? "Connect Apple Health" : "Refresh water ledger",
                        systemImage: isLoadingHealth ? "hourglass" : "heart.text.square.fill"
                    )
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
                }
                .foregroundStyle(accent)
                .buttonStyle(DumbPressStyle())
                .disabled(isLoadingHealth)
                .accessibilityIdentifier("importHydrationHealthButton")

                Text(healthWaterMilliliters == nil ? healthStatus : "Read-only. Manual servings remain the main ledger.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hydrationHealthCard")
    }

    private var progressCard: some View {
        DumbCard(accent: accent, isSelected: servings >= goal) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(accent.opacity(0.16), lineWidth: 10)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(accent, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Image(systemName: servings >= goal ? "checkmark" : "drop.fill")
                        .font(.title2.weight(.black))
                        .foregroundStyle(accent)
                }
                .frame(width: 84, height: 84)
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 5) {
                    DumbStatusPill(
                        servings >= goal ? "PERSONAL GOAL MET" : "BOTTLE WATCH",
                        systemImage: servings >= goal ? "checkmark.seal.fill" : "eye.fill",
                        accent: accent
                    )
                    Text("\(Int(servings)) of \(Int(goal)) servings")
                        .font(.title3.weight(.black))
                        .foregroundStyle(CorpPalette.ink)
                        .contentTransition(.numericText())
                    Text(servings >= goal ? "Your chosen target is complete." : "\(max(Int(goal - servings), 0)) more to your chosen target.")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .contentTransition(.opacity)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hydrationProgress")
        .accessibilityLabel("Hydration progress")
        .accessibilityValue("\(Int(servings)) of \(Int(goal)) servings")
    }

    private var notificationCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: "bell.badge.fill")
                        .font(.title3.weight(.black))
                        .foregroundStyle(accent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("BOTTLE CHECK-IN")
                            .font(.caption2.weight(.black))
                            .tracking(1.1)
                            .foregroundStyle(accent)
                        Text("One optional nudge to update your own ledger.")
                            .font(.subheadline.weight(.black))
                            .foregroundStyle(CorpPalette.ink)
                    }
                }
                Toggle("Remind me to log", isOn: $dailyNudgeEnabled)
                    .font(.subheadline.weight(.black))
                    .tint(accent)
                    .accessibilityIdentifier("hydrationDailyNudgeSwitch")
                DatePicker("Check-in time", selection: $nudgeDate, displayedComponents: .hourAndMinute)
                    .font(.subheadline.weight(.bold))
                    .disabled(!dailyNudgeEnabled)
                    .accessibilityIdentifier("hydrationNudgeTimePicker")
                Text(notificationMessage)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hydrationNotificationCard")
    }

    private var historyCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("SEVEN-DAY WATER LEDGER")
                        .font(.caption2.weight(.black))
                        .tracking(1.2)
                        .foregroundStyle(CorpPalette.mutedInk)
                    Spacer()
                    Text("\(history.count) days")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CorpPalette.mutedInk)
                }

                if history.isEmpty {
                    Label("Yesterday has filed no paperwork.", systemImage: "calendar")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(CorpPalette.ink)
                } else {
                    ForEach(history) { day in
                        HStack {
                            Text(displayDate(for: day.dayKey))
                                .font(.subheadline.weight(.black))
                                .foregroundStyle(CorpPalette.ink)
                            Spacer()
                            Text("\(day.servings) of \(day.goal)")
                                .font(.subheadline.weight(.black))
                                .foregroundStyle(accent)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityIdentifier("hydrationHistoryDay")
                        .accessibilityValue("\(day.dayKey): \(day.servings) of \(day.goal) servings")
                    }
                }
            }
        }
    }

    private var progress: CGFloat {
        CGFloat(min(max(servings / max(goal, 1), 0), 1))
    }

    private func syncWidgetSnapshot() {
        DumbWidgetSync.publish(.hydration, values: [
            "servings": "\(Int(servings.rounded()))",
            "goal": "\(Int(goal.rounded()))",
        ])
    }

    private func logOneServing() {
        servings = min(servings + 1, 24)
        reportToBottle()
    }

    private func undoOneServing() {
        servings = max(servings - 1, 0)
        reportToBottle()
    }

    private func reportToBottle() {
        let ratio = servings / max(goal, 1)
        result = ratio < 0.5
            ? "The bottle says: “A beginning. Management remains alert.”"
            : ratio < 1
                ? "The bottle says: “Progress noted. Continue at your own sensible pace.”"
                : "The bottle says: “Your chosen target is complete. Case closed.”"
        storedResult = result
    }

    private func resetToday() {
        servings = 0
        result = "Today's ledger is empty. Earlier daily summaries remain."
        storedResult = result
    }

    private func loadAndRollDay() {
        guard !hasLoaded else { return }
        hasLoaded = true
        restoreHistory()

        let today = currentDayKey()
        if !recordedDay.isEmpty, recordedDay != today {
            archiveRecordedDay()
        }
        if recordedDay != today {
            servings = 0
            storedResult = Self.emptyResult
            recordedDay = today
        }
        result = storedResult
    }

    private func archiveRecordedDay() {
        let summary = HydrationDay(dayKey: recordedDay, servings: Int(servings), goal: Int(goal))
        history.removeAll { $0.dayKey == recordedDay }
        history.insert(summary, at: 0)
        history = Array(history.prefix(7))
        persistHistory()
    }

    private func currentDayKey() -> String {
        let arguments = ProcessInfo.processInfo.arguments
        if let marker = arguments.firstIndex(of: "-UITestingDayOverride"), arguments.indices.contains(marker + 1) {
            return arguments[marker + 1]
        }
        let components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }

    private func displayDate(for dayKey: String) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dayKey) else { return dayKey }
        return date.formatted(date: .abbreviated, time: .omitted)
    }

    private func restoreHistory() {
        guard let data = storedHistory.data(using: .utf8), let saved = try? JSONDecoder().decode([HydrationDay].self, from: data) else { return }
        history = Array(saved.prefix(7))
    }

    private func persistHistory() {
        guard let data = try? JSONEncoder().encode(history), let value = String(data: data, encoding: .utf8) else { return }
        storedHistory = value
    }

    private func importHealthWater() {
        guard let waterType else {
            healthStatus = "Apple Health water is unavailable here. The manual ledger is ready."
            return
        }
        guard HKHealthStore.isHealthDataAvailable() else {
            healthStatus = "Apple Health is unavailable here. The manual ledger is ready."
            return
        }

        isLoadingHealth = true
        healthStore.requestAuthorization(toShare: [], read: [waterType]) { success, error in
            guard success, error == nil else {
                DispatchQueue.main.async {
                    isLoadingHealth = false
                    healthStatus = "Apple Health wasn’t shared. The manual ledger still works."
                }
                return
            }

            let end = Date()
            let start = Calendar.autoupdatingCurrent.startOfDay(for: end)
            let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
            let query = HKStatisticsQuery(
                quantityType: waterType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                let unit = HKUnit.literUnit(with: .milli)
                let importedWater = error == nil ? statistics?.sumQuantity()?.doubleValue(for: unit) ?? 0 : 0
                DispatchQueue.main.async {
                    isLoadingHealth = false
                    if importedWater > 0 {
                        healthWaterMilliliters = importedWater
                        healthConnected = true
                        healthStatus = "Using today’s read-only water entries from Apple Health."
                    } else {
                        healthWaterMilliliters = nil
                        healthConnected = true
                        healthStatus = "No water entries arrived from Apple Health. The manual ledger still works."
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
        notificationMessage = "Asking for permission, then scheduling one quiet-hours-aware bottle check-in."
        Task {
            let outcome = await DumbLocalNotifications.scheduleDaily(
                identifier: Self.notificationIdentifier,
                title: "Bottle check-in",
                body: "Your personal water ledger is waiting for one honest tap.",
                proposedTime: date
            )
            await MainActor.run {
                switch outcome {
                case .scheduled(let scheduledDate):
                    notificationMessage = "One bottle check-in scheduled for \(scheduledDate.formatted(date: .omitted, time: .shortened))."
                case .denied:
                    dailyNudgeEnabled = false
                    notificationMessage = "Notifications are off in Settings. The ledger still works without them."
                case .failed:
                    dailyNudgeEnabled = false
                    notificationMessage = "The bottle reminder did not stick. The ledger still works without it."
                }
            }
        }
    }
}
