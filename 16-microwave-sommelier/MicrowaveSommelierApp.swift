import SwiftUI
import DumbKit

private struct HeatConversion: Codable, Identifiable {
    let id: UUID
    let food: String
    let packageSeconds: Int
    let packageWattage: Int
    let microwaveWattage: Int
    let adjustedSeconds: Int
    let checkpointSeconds: Int
    let date: Date

    init(
        food: String,
        packageSeconds: Int,
        packageWattage: Int,
        microwaveWattage: Int,
        adjustedSeconds: Int,
        checkpointSeconds: Int,
        date: Date = Date()
    ) {
        id = UUID()
        self.food = food
        self.packageSeconds = packageSeconds
        self.packageWattage = packageWattage
        self.microwaveWattage = microwaveWattage
        self.adjustedSeconds = adjustedSeconds
        self.checkpointSeconds = checkpointSeconds
        self.date = date
    }
}

@main
struct MicrowaveSommelierApp: App {
    var body: some Scene { WindowGroup { MicrowaveView().dumbNativeEntry(scheme: "app16microwavesommelier") { _, _ in } } }
}

struct MicrowaveView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private static let emptyResult = "Present the package instructions. The tiny sommelier is listening."

    @AppStorage("microwaveSommelier.food") private var food = ""
    @AppStorage("microwaveSommelier.packageMinutes") private var packageMinutes = 4.0
    @AppStorage("microwaveSommelier.packageSeconds") private var packageSeconds = 0.0
    @AppStorage("microwaveSommelier.packageWattage") private var packageWattage = 1000.0
    @AppStorage("microwaveSommelier.wattage") private var microwaveWattage = 800.0
    @AppStorage("microwaveSommelier.result") private var result = Self.emptyResult
    @AppStorage("microwaveSommelier.history") private var storedHistory = "[]"
    @State private var packageTimeEntry = "4:00"

    @State private var history: [HeatConversion] = []
    @State private var hasLoaded = false
    @State private var showAllHistory = false
    @State private var showEraseConfirmation = false

    private let accent = CorpPalette.warningRed

    var body: some View {
        DumbShell(
            eyebrow: "CULINARY HEAT SCIENCE",
            title: "Microwave sommelier",
            subtitle: "Translate package timing between wattages, with unnecessary ceremony.",
            accent: accent,
            personality: .dramatic
        ) {
            formulaCard
            conversionEditor

            DumbAction(
                title: "Convert & file the pairing",
                accent: accent,
                systemImage: "microwave.fill",
                action: convertHeat
            )
            .disabled(totalPackageSeconds == 0)
            .accessibilityIdentifier("pairHeatButton")

            DumbResult(
                text: result,
                accent: accent,
                systemImage: "timer",
                reactionStyle: .bounce
            )
            .accessibilityIdentifier("microwaveConversionResult")

            Button(action: resetCurrentConversion) {
                Label("Reset current pairing", systemImage: "arrow.counterclockwise")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(!hasCurrentConversion)
            .accessibilityIdentifier("resetMicrowaveButton")

            historyCard

            Button {
                showEraseConfirmation = true
            } label: {
                Label("Erase every conversion", systemImage: "trash.fill")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(history.isEmpty && !hasCurrentConversion)
            .accessibilityIdentifier("eraseMicrowaveDataButton")
        }
        .onAppear {
            restoreHistory()
            syncPackageTimeEntryFromSliders()
        }
        .onChange(of: food) { _, _ in invalidateConversion() }
        .onChange(of: packageMinutes) { _, _ in invalidateConversion() }
        .onChange(of: packageSeconds) { _, _ in invalidateConversion() }
        .onChange(of: packageWattage) { _, _ in invalidateConversion() }
        .onChange(of: microwaveWattage) { _, _ in invalidateConversion() }
        .confirmationDialog(
            "Erase the current pairing and complete conversion history?",
            isPresented: $showEraseConfirmation,
            titleVisibility: .visible
        ) {
            Button("Confirm erase every conversion", role: .destructive, action: eraseAllData)
            Button("Keep the tasting notes", role: .cancel) {}
        } message: {
            Text("This erases every microwave conversion. It cannot be undone.")
        }
    }

    private var formulaCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 7) {
                DumbStatusPill(
                    "PUBLISHED FORMULA",
                    systemImage: "divide.circle.fill",
                    accent: accent
                )
                Text("We adjust the package time for your microwave’s wattage. Always check the food before eating.")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CorpPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var conversionEditor: some View {
        DumbCard(accent: accent, isSelected: packageWattage != microwaveWattage) {
            VStack(alignment: .leading, spacing: 14) {
                Text("READ THE PACKAGE LABEL")
                    .font(.caption2.weight(.black))
                    .tracking(1.2)
                    .foregroundStyle(CorpPalette.mutedInk)

                DumbField("What are you heating (optional)", maxLength: 100, text: $food)

                DumbField("Package time (mm:ss)", maxLength: 8, text: $packageTimeEntry)
                    .accessibilityIdentifier("microwavePackageTimeField")
                    .onChange(of: packageTimeEntry) { _, value in
                        applyPackageTimeEntry(value)
                    }

                if totalPackageSeconds > 0, microwaveWattage > 0 {
                    let preview = roundedToFive(
                        Double(totalPackageSeconds) * packageWattage / microwaveWattage
                    )
                    Text("Live preview: \(clockTime(totalPackageSeconds)) at \(Int(packageWattage)) W → \(clockTime(preview)) at \(Int(microwaveWattage)) W (rounded to 5 sec)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(accent)
                        .fixedSize(horizontal: false, vertical: true)
                }

                DumbSlider(
                    title: "Package minutes",
                    value: $packageMinutes,
                    range: 0...15,
                    step: 1,
                    accent: accent
                )
                .onChange(of: packageMinutes) { _, _ in syncPackageTimeEntryFromSliders() }
                DumbSlider(
                    title: "Package extra seconds",
                    value: $packageSeconds,
                    range: 0...45,
                    step: 15,
                    accent: accent
                )
                .onChange(of: packageSeconds) { _, _ in syncPackageTimeEntryFromSliders() }
                DumbSlider(
                    title: "Package instruction wattage",
                    value: $packageWattage,
                    range: 500...1200,
                    step: 50,
                    accent: accent
                )
                DumbSlider(
                    title: "Your microwave wattage",
                    value: $microwaveWattage,
                    range: 500...1200,
                    step: 50,
                    accent: accent
                )

                Text("Use the wattage printed on the package and microwave. If one is missing, treat the result as a rough estimate.")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CorpPalette.mutedInk)
            }
        }
    }

    private var historyCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 11) {
                HStack {
                    Text("PAIRING CELLAR")
                        .font(.caption2.weight(.black))
                        .tracking(1.2)
                        .foregroundStyle(CorpPalette.mutedInk)
                    Spacer()
                    Text("\(history.count) conversions")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .accessibilityIdentifier("microwaveHistoryCount")
                        .accessibilityValue("\(history.count)")
                }

                if history.isEmpty {
                    Label("The conversion cellar is empty.", systemImage: "wineglass")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(CorpPalette.ink)
                        .accessibilityIdentifier("emptyMicrowaveHistory")
                } else {
                    ForEach(visibleHistory) { conversion in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                DumbStatusPill(
                                    formatTime(conversion.adjustedSeconds).uppercased(),
                                    systemImage: "microwave.fill",
                                    accent: accent
                                )
                                Spacer()
                                Text(conversion.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(CorpPalette.mutedInk)
                            }
                            Text(conversion.food.isEmpty ? "Unnamed dish" : conversion.food)
                                .font(.headline.weight(.black))
                                .foregroundStyle(CorpPalette.ink)
                            Text("\(clockTime(conversion.packageSeconds)) at \(conversion.packageWattage) W → \(clockTime(conversion.adjustedSeconds)) at \(conversion.microwaveWattage) W")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(CorpPalette.ink)
                            Button(role: .destructive) {
                                delete(conversion)
                            } label: {
                                Label("Delete microwave conversion", systemImage: "trash")
                                    .font(.caption.weight(.black))
                            }
                            .accessibilityIdentifier("deleteMicrowaveConversionButton")
                        }
                        .padding(.vertical, 3)
                    }

                    if history.count > 5 {
                        Button(showAllHistory ? "Show newest five" : "Browse all \(history.count)") {
                            withAnimation(reduceMotion ? nil : .snappy) { showAllHistory.toggle() }
                        }
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(accent)
                        .accessibilityIdentifier("toggleMicrowaveHistoryButton")
                    }
                }
            }
        }
    }

    private var visibleHistory: [HeatConversion] {
        showAllHistory ? history : Array(history.prefix(5))
    }

    private var totalPackageSeconds: Int {
        Int(packageMinutes) * 60 + Int(packageSeconds)
    }

    private var hasCurrentConversion: Bool {
        !food.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || packageMinutes != 4
            || packageSeconds != 0
            || packageWattage != 1000
            || microwaveWattage != 800
            || result != Self.emptyResult
    }

    private func convertHeat() {
        guard totalPackageSeconds > 0 else { return }
        let adjusted = roundedToFive(
            Double(totalPackageSeconds) * packageWattage / microwaveWattage
        )
        let checkpoint = roundedToFive(Double(adjusted) * 0.8)
        let conversion = HeatConversion(
            food: food.trimmingCharacters(in: .whitespacesAndNewlines),
            packageSeconds: totalPackageSeconds,
            packageWattage: Int(packageWattage),
            microwaveWattage: Int(microwaveWattage),
            adjustedSeconds: adjusted,
            checkpointSeconds: checkpoint
        )

        result = "Converted time: \(formatTime(adjusted)). \(clockTime(totalPackageSeconds)) at \(Int(packageWattage)) W → \(clockTime(adjusted)) at \(Int(microwaveWattage)) W. First checkpoint: \(formatTime(checkpoint)); then check or stir and continue in short bursts if needed. Timing conversion only—not a temperature or safety guarantee."
        history.insert(conversion, at: 0)
        history = Array(history.prefix(20))
        persistHistory()
    }

    private func roundedToFive(_ seconds: Double) -> Int {
        max(Int((seconds / 5).rounded()) * 5, 5)
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainder = seconds % 60
        if minutes == 0 { return "\(remainder) sec" }
        if remainder == 0 { return "\(minutes) min" }
        return "\(minutes) min \(remainder) sec"
    }

    private func clockTime(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    private func syncPackageTimeEntryFromSliders() {
        packageTimeEntry = clockTime(totalPackageSeconds)
    }

    private func applyPackageTimeEntry(_ value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if trimmed.contains(":") {
            let parts = trimmed.split(separator: ":", maxSplits: 1)
            guard parts.count == 2,
                  let minutes = Int(parts[0]),
                  let seconds = Int(parts[1]),
                  minutes >= 0, seconds >= 0, seconds < 60 else { return }
            packageMinutes = Double(min(minutes, 15))
            packageSeconds = Double(min((seconds / 15) * 15, 45))
        } else if let minutesOnly = Int(trimmed), minutesOnly >= 0 {
            packageMinutes = Double(min(minutesOnly, 15))
            packageSeconds = 0
        }
    }

    private func invalidateConversion() {
        guard result != Self.emptyResult else { return }
        result = "Pairing changed. Convert a fresh microwave time."
    }

    private func resetCurrentConversion() {
        food = ""
        packageMinutes = 4
        packageSeconds = 0
        packageWattage = 1000
        microwaveWattage = 800
        packageTimeEntry = "4:00"
        result = Self.emptyResult
    }

    private func delete(_ conversion: HeatConversion) {
        history.removeAll { $0.id == conversion.id }
        persistHistory()
    }

    private func eraseAllData() {
        history = []
        showAllHistory = false
        resetCurrentConversion()
        persistHistory()
    }

    private func restoreHistory() {
        guard !hasLoaded else { return }
        hasLoaded = true
        guard
            let data = storedHistory.data(using: .utf8),
            let saved = try? JSONDecoder().decode([HeatConversion].self, from: data)
        else { return }
        history = saved.sorted { $0.date > $1.date }
    }

    private func persistHistory() {
        guard
            let data = try? JSONEncoder().encode(history),
            let value = String(data: data, encoding: .utf8)
        else { return }
        storedHistory = value
    }
}
