@preconcurrency import CoreLocation
import FoundationModels
import HealthKit
@preconcurrency import MapKit
import Observation
import SwiftUI
import DumbKit

@main
struct StepDebtApp: App {
    var body: some Scene {
        WindowGroup { StepDebtView() }
    }
}

private struct StepDebtCoordinate: Equatable {
    let latitude: Double
    let longitude: Double

    init(_ coordinate: CLLocationCoordinate2D) {
        latitude = coordinate.latitude
        longitude = coordinate.longitude
    }

    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

private enum RouteLookupError: Error {
    case noDestination
    case noRoute
}

@MainActor
@Observable
private final class StepDebtLocationService: NSObject, @preconcurrency CLLocationManagerDelegate {
    @ObservationIgnored private let manager = CLLocationManager()
    @ObservationIgnored private var shouldRequestLocationAfterAuthorization = false

    private(set) var lastCoordinate: StepDebtCoordinate?
    private(set) var statusMessage = "A nearby walking route is optional."
    private(set) var isWorking = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestCurrentLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            statusMessage = "Location Services are off. You can still use the invoice without a route."
            return
        }

        switch manager.authorizationStatus {
        case .notDetermined:
            shouldRequestLocationAfterAuthorization = true
            isWorking = true
            statusMessage = "Waiting for your location choice…"
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            isWorking = true
            statusMessage = "Finding a small place to walk to…"
            manager.requestLocation()
        case .denied, .restricted:
            isWorking = false
            statusMessage = "Location access is off. Open Settings or keep the invoice local."
        @unknown default:
            isWorking = false
            statusMessage = "Location status is unknown. The invoice still works without it."
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            guard shouldRequestLocationAfterAuthorization else { return }
            shouldRequestLocationAfterAuthorization = false
            isWorking = true
            statusMessage = "Finding a small place to walk to…"
            manager.requestLocation()
        case .denied, .restricted:
            shouldRequestLocationAfterAuthorization = false
            isWorking = false
            statusMessage = "Location access is off. The invoice still works without a route."
        case .notDetermined:
            break
        @unknown default:
            shouldRequestLocationAfterAuthorization = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        isWorking = false
        guard let location = locations.last else {
            statusMessage = "No position arrived. The invoice still works without a route."
            return
        }
        lastCoordinate = StepDebtCoordinate(location.coordinate)
        statusMessage = "Position found. Looking for a walk-sized destination…"
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isWorking = false
        statusMessage = "Could not get a position. The invoice still works without a route."
    }
}

struct StepDebtView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("stepDebt.actual") private var actual = 3400.0
    @AppStorage("stepDebt.goal") private var goal = 8000.0
    @AppStorage("stepDebt.goalWasEdited") private var goalWasEdited = false
    @AppStorage("stepDebt.healthConnected") private var healthConnected = false
    @AppStorage("stepDebt.manualMode") private var manualMode = false
    @AppStorage("stepDebt.dailyNudgeEnabled") private var dailyNudgeEnabled = false
    @AppStorage("stepDebt.nudgeHour") private var nudgeHour = 18
    @AppStorage("stepDebt.nudgeMinute") private var nudgeMinute = 0

    @State private var result = "The step accountant is asleep."
    @State private var healthSteps: Double?
    @State private var baselineSteps: Double?
    @State private var healthStatus = "Connect Apple Health to use today’s real steps."
    @State private var goalSource = "Starter target. Edit it whenever you want."
    @State private var isLoadingHealth = false
    @State private var manualEditorVisible = false
    @State private var routeStatus = "A short closing walk is optional."
    @State private var routeOrigin: StepDebtCoordinate?
    @State private var routeDestination: StepDebtCoordinate?
    @State private var routeDestinationName = ""
    @State private var routeDistance: Double?
    @State private var routeDuration: TimeInterval?
    @State private var routeEstimatedSteps = 0
    @State private var isRouting = false
    @State private var isWaitingForLocation = false
    @State private var notificationMessage = "Off. One optional check-in, never a guilt loop."
    @State private var nudgeDate = Date()
    @State private var didLoadNudgeDate = false
    @State private var modelStatus = "The local joke clerk is on standby."
    @State private var isGeneratingJoke = false
    @State private var generationID: UUID?
    @State private var locationService = StepDebtLocationService()

    private let accent = CorpPalette.parkGreen
    private let healthStore = HKHealthStore()
    private static let notificationIdentifier = "step-debt.daily-check-in"

    private var stepType: HKQuantityType? {
        HKObjectType.quantityType(forIdentifier: .stepCount)
    }

    private var effectiveSteps: Double {
        healthSteps ?? actual
    }

    private var progress: CGFloat {
        CGFloat(min(max(effectiveSteps / max(goal, 1), 0), 1))
    }

    private var remainingSteps: Int {
        max(Int((goal - effectiveSteps).rounded()), 0)
    }

    private var forceFallbackForUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("-UITestingForceFallback")
    }

    var body: some View {
        DumbShell(
            eyebrow: "MOVEMENT ACCOUNTING",
            title: "Step debt",
            subtitle: "A fictional invoice for a walk you may or may not owe.",
            accent: accent,
            personality: .office,
            experience: .wellness
        ) {
            progressCard

            DumbAction(
                title: "Stamp today’s invoice",
                accent: accent,
                systemImage: "figure.walk",
                action: calculateDebt
            )
            .accessibilityIdentifier("calculateStepDebtButton")

            DumbResult(
                text: result,
                accent: accent,
                systemImage: "creditcard.fill",
                reactionStyle: .stamp
            )
            .accessibilityIdentifier("stepDebtResult")

            modelStatusView

            DisclosureGroup {
                healthConnectionCard
                    .padding(.top, 8)
            } label: {
                Label("Apple Health connection", systemImage: "heart.text.square.fill")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(CorpPalette.ink)
            }

            DisclosureGroup {
                routeCard
                    .padding(.top, 8)
            } label: {
                Label("Optional closing walk", systemImage: "map.fill")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(CorpPalette.ink)
            }

            DisclosureGroup {
                VStack(spacing: 12) {
                    notificationCard
                    manualFallbackCard
                }
                .padding(.top, 8)
            } label: {
                Label("Reminders and manual entry", systemImage: "slider.horizontal.3")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(CorpPalette.ink)
            }

            Button(action: reset) {
                Label("Reset the ledger", systemImage: "arrow.counterclockwise")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .accessibilityIdentifier("resetStepDebtButton")
        }
        .onAppear {
            loadNudgeDate()
            if healthConnected && !manualMode { importHealthSteps() }
            if manualMode {
                manualEditorVisible = true
                healthStatus = "Manual estimate active. Apple Health remains optional."
            }
        }
        .onChange(of: locationService.lastCoordinate) { _, coordinate in
            guard isWaitingForLocation, let coordinate else { return }
            isWaitingForLocation = false
            findWalkingRoute(from: coordinate)
        }
        .onChange(of: locationService.statusMessage) { _, message in
            guard isWaitingForLocation else { return }
            routeStatus = message
            if !locationService.isWorking, message != "Waiting for your location choice…" {
                isWaitingForLocation = false
            }
        }
        .onChange(of: dailyNudgeEnabled) { _, enabled in
            if enabled {
                scheduleDailyNudge()
            } else {
                DumbLocalNotifications.cancel(identifier: Self.notificationIdentifier)
                notificationMessage = "Off. One optional check-in, never a guilt loop."
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
        DumbCard(accent: accent, isSelected: healthSteps != nil) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(accent.opacity(0.14))
                            .frame(width: 54, height: 54)
                        Image(systemName: "heart.text.square.fill")
                            .font(.title2.weight(.black))
                            .foregroundStyle(accent)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(healthSteps == nil ? "APPLE HEALTH CONNECTION" : "APPLE HEALTH CONNECTED")
                            .font(.caption2.weight(.black))
                            .tracking(1.1)
                            .foregroundStyle(accent)
                        Text(healthSteps == nil ? "Bring the real steps." : "Today’s count is doing the paperwork.")
                            .font(.headline.weight(.black))
                            .foregroundStyle(CorpPalette.ink)
                    }
                }

                if let healthSteps {
                    Text("\(Int(healthSteps.rounded())) steps today")
                        .font(.title2.weight(.black))
                        .foregroundStyle(CorpPalette.ink)
                        .contentTransition(.numericText())
                    Text(healthStatus)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CorpPalette.mutedInk)
                } else {
                    Text("One tap imports today’s step count. The app only reads it; it never writes or uploads it.")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(CorpPalette.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Button(action: importHealthSteps) {
                    Label(
                        isLoadingHealth
                            ? "Checking Apple Health…"
                            : healthSteps == nil ? "Connect Apple Health" : "Refresh Apple Health",
                        systemImage: isLoadingHealth ? "hourglass" : "heart.text.square.fill"
                    )
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
                }
                .foregroundStyle(accent)
                .buttonStyle(DumbPressStyle())
                .disabled(isLoadingHealth)
                .accessibilityIdentifier("importHealthStepsButton")

                Text(healthSteps == nil ? healthStatus : "Read-only. You can switch back to a manual estimate below.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("stepDebtHealthCard")
    }

    private var progressCard: some View {
        DumbCard(accent: accent, isSelected: effectiveSteps >= goal) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(effectiveSteps >= goal ? "DEBT CLEARED" : "CURRENT BALANCE")
                            .font(.caption2.weight(.black))
                            .tracking(1.1)
                            .foregroundStyle(accent)
                        Text(effectiveSteps >= goal ? "Paid in footsteps." : "\(remainingSteps) steps due")
                            .font(.title2.weight(.black))
                            .foregroundStyle(CorpPalette.ink)
                    }
                    Spacer()
                    Text("\(Int(effectiveSteps.rounded()))")
                        .font(.system(.title, design: .rounded).weight(.black))
                        .foregroundStyle(accent)
                        .contentTransition(.numericText())
                    Text("steps")
                        .font(.caption.weight(.black))
                        .foregroundStyle(CorpPalette.mutedInk)
                }

                ProgressView(value: progress)
                    .tint(accent)
                    .scaleEffect(x: 1, y: 1.7, anchor: .center)
                    .accessibilityLabel("Step progress")
                    .accessibilityValue("\(Int(progress * 100)) percent of target")

                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "target")
                        .foregroundStyle(accent)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Target: \(Int(goal.rounded())) steps")
                            .font(.subheadline.weight(.black))
                            .foregroundStyle(CorpPalette.ink)
                        Text(goalSource)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CorpPalette.mutedInk)
                    }
                    Spacer(minLength: 0)
                }

                Button("Change target") {
                    withAnimation(reduceMotion ? nil : DumbMotion.quick) { manualEditorVisible = true }
                }
                .font(.caption.weight(.black))
                .foregroundStyle(accent)
                .buttonStyle(DumbPressStyle())
                .accessibilityIdentifier("stepDebtChangeGoalButton")
            }
        }
        .accessibilityIdentifier("stepDebtProgressCard")
    }

    private var modelStatusView: some View {
        HStack(spacing: 8) {
            if isGeneratingJoke { ProgressView().tint(accent) }
            Text(modelStatus)
                .font(.caption.weight(.semibold))
                .foregroundStyle(CorpPalette.mutedInk)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("stepDebtModelStatus")
    }

    private var routeCard: some View {
        DumbCard(accent: accent, isSelected: routeEstimatedSteps > 0) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    DumbStatusPill("CLOSING WALK", systemImage: "map.fill", accent: accent)
                    Spacer(minLength: 0)
                    if isRouting { ProgressView().tint(accent) }
                }

                Text("Need a silly payment plan? We’ll find a nearby park and hand the walking directions to Apple Maps.")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CorpPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)

                if routeEstimatedSteps > 0, let routeDistance, let routeDuration {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(routeDestinationName)
                            .font(.headline.weight(.black))
                            .foregroundStyle(CorpPalette.ink)
                        Text("~\(routeEstimatedSteps) steps · \(distanceText(routeDistance)) · \(Int((routeDuration / 60).rounded())) min")
                            .font(.subheadline.weight(.black))
                            .foregroundStyle(accent)
                        Text(routeCoverageText)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CorpPalette.mutedInk)
                    }

                    Button(action: openWalkingDirections) {
                        Label("Open walking directions in Apple Maps", systemImage: "arrow.up.right.square.fill")
                            .font(.subheadline.weight(.black))
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .foregroundStyle(accent)
                    .buttonStyle(DumbPressStyle())
                    .accessibilityIdentifier("openWalkingDirectionsButton")
                } else {
                    Text(routeStatus)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CorpPalette.mutedInk)

                    Button(action: findStepClosingRoute) {
                        Label(isRouting ? "Finding a route…" : "Find my closing walk", systemImage: "location.fill")
                            .font(.subheadline.weight(.black))
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .foregroundStyle(accent)
                    .buttonStyle(DumbPressStyle())
                    .disabled(isRouting)
                    .accessibilityIdentifier("findStepClosingRouteButton")
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("stepDebtRouteCard")
    }

    private var routeCoverageText: String {
        guard remainingSteps > 0 else { return "The invoice is already cleared. This is now a victory lap." }
        let covered = min(routeEstimatedSteps, remainingSteps)
        return covered >= remainingSteps
            ? "This route would cover the whole fictional balance, approximately."
            : "This route covers about \(covered) of the \(remainingSteps) steps due."
    }

    private var notificationCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "bell.badge.fill")
                        .font(.title3.weight(.black))
                        .foregroundStyle(accent)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("ONE TINY CHECK-IN")
                            .font(.caption2.weight(.black))
                            .tracking(1.1)
                            .foregroundStyle(accent)
                        Text("A gentle nudge, not a guilt machine.")
                            .font(.subheadline.weight(.black))
                            .foregroundStyle(CorpPalette.ink)
                    }
                }

                Toggle("Daily accountant check-in", isOn: $dailyNudgeEnabled)
                    .font(.subheadline.weight(.black))
                    .tint(accent)
                    .accessibilityIdentifier("stepDebtDailyNudgeSwitch")

                DatePicker("Check-in time", selection: $nudgeDate, displayedComponents: .hourAndMinute)
                    .font(.subheadline.weight(.bold))
                    .disabled(!dailyNudgeEnabled)
                    .accessibilityIdentifier("stepDebtNudgeTimePicker")

                Text(notificationMessage)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("stepDebtNotificationCard")
    }

    private var manualFallbackCard: some View {
        DumbCard(accent: accent) {
            DisclosureGroup(isExpanded: $manualEditorVisible) {
                VStack(alignment: .leading, spacing: 10) {
                    DumbSlider(
                        title: "Target: \(Int(goal.rounded())) steps",
                        value: Binding(
                            get: { goal },
                            set: { newValue in
                                goal = newValue
                                goalWasEdited = true
                                goalSource = "Custom target. Apple Health supplies steps, not a step goal."
                            }
                        ),
                        range: 3000...12000,
                        step: 500,
                        accent: accent
                    )
                    .accessibilityIdentifier("stepDebtGoalSlider")

                    DumbSlider(
                        title: "Manual steps: \(Int(actual.rounded()))",
                        value: $actual,
                        range: 0...20000,
                        step: 100,
                        accent: accent
                    )
                    .disabled(healthSteps != nil)
                    .accessibilityIdentifier("stepDebtManualSlider")

                    if healthSteps != nil {
                        Button("Switch to manual estimate") {
                            healthSteps = nil
                            manualMode = true
                            manualEditorVisible = true
                            healthStatus = "Manual estimate active. Apple Health remains optional."
                        }
                        .font(.caption.weight(.black))
                        .foregroundStyle(accent)
                        .buttonStyle(DumbPressStyle())
                    } else {
                        Text("The target above can stay smart or be changed. Manual steps are the backup for the simulator, offline use, or whenever you’d rather not connect Health.")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CorpPalette.mutedInk)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.top, 10)
            } label: {
                Label(
                    healthSteps == nil ? "Enter steps manually" : "Manual estimate",
                    systemImage: "slider.horizontal.3"
                )
                .font(.subheadline.weight(.black))
                .foregroundStyle(CorpPalette.ink)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("stepDebtInput")
    }

    private func calculateDebt() {
        let currentSteps = effectiveSteps
        let difference = max(goal - currentSteps, 0)
        result = difference == 0
            ? "No debt. You have been released from movement bankruptcy."
            : "You owe \(Int(difference.rounded())) steps. Payment plan: walk somewhere mildly interesting."
        modelStatus = "The local joke clerk is checking the receipt."
        requestOnDeviceJoke(steps: currentSteps, target: goal, routeSteps: routeEstimatedSteps)
    }

    private func requestOnDeviceJoke(steps: Double, target: Double, routeSteps: Int) {
        generationID = UUID()
        let currentGenerationID = generationID
        isGeneratingJoke = true

        Task {
            let generated: String?
            if forceFallbackForUITesting {
                generated = nil
            } else if #available(iOS 26.0, *) {
                generated = await generateOnDeviceJoke(steps: steps, target: target, routeSteps: routeSteps)
            } else {
                generated = nil
            }

            await MainActor.run {
                guard generationID == currentGenerationID else { return }
                isGeneratingJoke = false
                generationID = nil
                if let generated {
                    result = generated
                    modelStatus = "Joke supplied by the on-device clerk."
                } else {
                    modelStatus = "Local backup joke used. No health data left the phone."
                }
            }
        }
    }

    @available(iOS 26.0, *)
    private func generateOnDeviceJoke(steps: Double, target: Double, routeSteps: Int) async -> String? {
        guard SystemLanguageModel.default.isAvailable else { return nil }

        let session = LanguageModelSession(instructions: """
        You are the fictional Step Debt invoice clerk. Return one or two short, warm,
        absurd sentences about a user's walking invoice. This is entertainment, not
        medical, fitness, or treatment advice. Never shame the user, never make health
        claims, and never tell them what they must do. Mention a tiny imaginary payment
        plan only if it is funny. Return only the joke text.
        """)

        let prompt = "Steps today: \(Int(steps.rounded())). Playful target: \(Int(target.rounded())). Suggested route steps: \(routeSteps)."
        do {
            let response = try await session.respond(to: prompt)
            let text = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { return nil }
            return String(text.prefix(320))
        } catch {
            return nil
        }
    }

    private func reset() {
        generationID = nil
        isGeneratingJoke = false
        actual = 3400
        goal = 8000
        goalWasEdited = false
        result = "The step accountant is asleep."
        healthSteps = nil
        baselineSteps = nil
        healthStatus = "Connect Apple Health to use today’s real steps."
        manualMode = false
        goalSource = "Starter target. Edit it whenever you want."
        manualEditorVisible = false
        routeStatus = "A short closing walk is optional."
        routeOrigin = nil
        routeDestination = nil
        routeDestinationName = ""
        routeDistance = nil
        routeDuration = nil
        routeEstimatedSteps = 0
        isRouting = false
        isWaitingForLocation = false
        dailyNudgeEnabled = false
        DumbLocalNotifications.cancel(identifier: Self.notificationIdentifier)
        notificationMessage = "Off. One optional check-in, never a guilt loop."
        modelStatus = "The local joke clerk is on standby."
    }

    private func importHealthSteps() {
        if forceFallbackForUITesting {
            healthSteps = nil
            manualEditorVisible = true
            isLoadingHealth = false
            healthStatus = "Manual fallback is active for this test. Apple Health remains optional."
            return
        }

        manualMode = false

        guard let stepType else {
            manualEditorVisible = true
            healthStatus = "Apple Health is unavailable here. Enter steps manually below."
            return
        }
        guard HKHealthStore.isHealthDataAvailable() else {
            manualEditorVisible = true
            healthStatus = "Apple Health is unavailable here. Enter steps manually below."
            return
        }

        isLoadingHealth = true
        healthStore.requestAuthorization(toShare: [], read: [stepType]) { success, error in
            guard success, error == nil else {
                DispatchQueue.main.async {
                    isLoadingHealth = false
                    manualEditorVisible = true
                    healthStatus = "Apple Health wasn’t shared. Enter steps manually below."
                }
                return
            }
            readHealthStepHistory(stepType: stepType)
        }
    }

    private func readHealthStepHistory(stepType: HKQuantityType) {
        let calendar = Calendar.autoupdatingCurrent
        let now = Date()
        let today = calendar.startOfDay(for: now)
        let historyStart = calendar.date(byAdding: .day, value: -14, to: today) ?? today
        let predicate = HKQuery.predicateForSamples(withStart: historyStart, end: now, options: .strictStartDate)
        let query = HKStatisticsCollectionQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: today,
            intervalComponents: DateComponents(day: 1)
        )

        query.initialResultsHandler = { _, collection, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    isLoadingHealth = false
                    manualEditorVisible = true
                    healthStatus = "Apple Health could not be read right now. Enter steps manually below."
                }
                return
            }

            var todaySteps = 0.0
            var previousDays: [Double] = []
            let enumerationEnd = calendar.date(byAdding: .day, value: 1, to: today) ?? now
            collection?.enumerateStatistics(from: historyStart, to: enumerationEnd) { statistics, _ in
                let value = statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0
                if calendar.isDate(statistics.startDate, inSameDayAs: today) {
                    todaySteps = value
                } else if value > 0 {
                    previousDays.append(value)
                }
            }

            let baseline = Self.median(previousDays)
            let computedGoal = Self.smartGoal(from: baseline)

            DispatchQueue.main.async {
                isLoadingHealth = false
                healthSteps = todaySteps
                baselineSteps = baseline
                healthConnected = true
                if baseline != nil, !goalWasEdited {
                    let previousGoal = goal
                    goal = computedGoal
                    goalSource = baseline.map { baselineValue in
                        "Smart target: 5% above your recent median of \(Int(baselineValue.rounded())) steps (was \(Int(previousGoal.rounded())))."
                    } ?? goalSource
                } else if baseline == nil, !goalWasEdited {
                    goal = 8000
                    goalSource = "Starter target: Apple Health has no recent baseline yet (editable)."
                } else {
                    goalSource = "Your custom target. Apple Health supplies steps, not a step goal."
                }
                healthStatus = todaySteps > 0
                    ? "Using today’s read-only step count from Apple Health."
                    : "Apple Health is connected, but no steps are logged today. Manual mode remains available."
            }
        }
        healthStore.execute(query)
    }

    private static func median(_ values: [Double]) -> Double? {
        let sorted = values.filter { $0 > 0 }.sorted()
        guard !sorted.isEmpty else { return nil }
        if sorted.count % 2 == 1 { return sorted[sorted.count / 2] }
        let upper = sorted.count / 2
        return (sorted[upper - 1] + sorted[upper]) / 2
    }

    private static func smartGoal(from baseline: Double?) -> Double {
        guard let baseline, baseline > 0 else { return 8000 }
        let rounded = (baseline * 1.05 / 500).rounded() * 500
        return min(max(rounded, 3000), 12000)
    }

    private func findStepClosingRoute() {
        routeDestination = nil
        routeDestinationName = ""
        routeDistance = nil
        routeDuration = nil
        routeEstimatedSteps = 0
        routeStatus = "A route needs your location only for this request."

        if let coordinate = locationService.lastCoordinate {
            findWalkingRoute(from: coordinate)
        } else {
            isWaitingForLocation = true
            locationService.requestCurrentLocation()
        }
    }

    private func findWalkingRoute(from origin: StepDebtCoordinate) {
        routeOrigin = origin
        isRouting = true
        routeStatus = "Finding a nearby park and asking for walking directions…"

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "park"
        request.region = MKCoordinateRegion(
            center: origin.clCoordinate,
            latitudinalMeters: 3500,
            longitudinalMeters: 3500
        )

        Task { @MainActor in
            do {
                let response = try await MKLocalSearch(request: request).start()
                let originLocation = CLLocation(latitude: origin.latitude, longitude: origin.longitude)
                let item = response.mapItems.min {
                    let firstDistance = $0.placemark.location?.distance(from: originLocation) ?? .greatestFiniteMagnitude
                    let secondDistance = $1.placemark.location?.distance(from: originLocation) ?? .greatestFiniteMagnitude
                    return firstDistance < secondDistance
                }
                guard let item else { throw RouteLookupError.noDestination }

                let directionsRequest = MKDirections.Request()
                directionsRequest.source = MKMapItem(
                    placemark: MKPlacemark(coordinate: origin.clCoordinate)
                )
                directionsRequest.destination = item
                directionsRequest.transportType = .walking

                let directionsResponse = try await MKDirections(request: directionsRequest).calculate()
                guard let route = directionsResponse.routes.min(by: { $0.distance < $1.distance }) else {
                    throw RouteLookupError.noRoute
                }

                routeDestinationName = item.name ?? "Nearby park"
                routeDistance = route.distance
                routeDuration = route.expectedTravelTime
                routeEstimatedSteps = max(Int((route.distance / 0.75).rounded()), 1)
                routeDestination = StepDebtCoordinate(item.placemark.coordinate)
                routeStatus = "Route found. Step estimate uses ~0.75 m per step — a rough fiction, not a guarantee."
                isRouting = false
            } catch RouteLookupError.noDestination {
                isRouting = false
                routeStatus = "No nearby park route appeared. Try again or use the invoice without one."
            } catch {
                isRouting = false
                routeStatus = "Apple Maps could not calculate a walk here. The invoice still works."
            }
        }
    }

    private func openWalkingDirections() {
        guard let origin = routeOrigin, let destination = routeDestination else { return }
        let sourceItem = MKMapItem(placemark: MKPlacemark(coordinate: origin.clCoordinate))
        sourceItem.name = "Current location"
        let destinationItem = MKMapItem(placemark: MKPlacemark(coordinate: destination.clCoordinate))
        destinationItem.name = routeDestinationName
        MKMapItem.openMaps(
            with: [sourceItem, destinationItem],
            launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        )
    }

    private func distanceText(_ meters: Double) -> String {
        meters >= 1000
            ? String(format: "%.1f km", meters / 1000)
            : "\(Int(meters.rounded())) m"
    }

    private func loadNudgeDate() {
        guard !didLoadNudgeDate else { return }
        didLoadNudgeDate = true
        let calendar = Calendar.autoupdatingCurrent
        nudgeDate = calendar.date(
            bySettingHour: nudgeHour,
            minute: nudgeMinute,
            second: 0,
            of: Date()
        ) ?? Date()
    }

    private func scheduleDailyNudge() {
        let proposedDate = Calendar.autoupdatingCurrent.date(
            bySettingHour: nudgeHour,
            minute: nudgeMinute,
            second: 0,
            of: Date()
        ) ?? Date()

        notificationMessage = "Asking for permission, then scheduling one quiet-hours-aware check-in."
        Task {
            let scheduleResult = await DumbLocalNotifications.scheduleDaily(
                identifier: Self.notificationIdentifier,
                title: "Step Debt check-in",
                body: "Your tiny movement invoice is still open. A short walk is available if you want it.",
                proposedTime: proposedDate
            )
            await MainActor.run {
                switch scheduleResult {
                case .scheduled(let date):
                    notificationMessage = "One check-in scheduled for \(date.formatted(date: .omitted, time: .shortened))."
                case .denied:
                    dailyNudgeEnabled = false
                    notificationMessage = "Notifications are off in Settings. The invoice still works without them."
                case .failed:
                    dailyNudgeEnabled = false
                    notificationMessage = "That reminder did not stick. The invoice still works without it."
                }
            }
        }
    }
}
