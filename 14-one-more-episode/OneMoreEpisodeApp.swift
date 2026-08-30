import SwiftUI
import DumbKit

private struct EpisodeForecast: Codable, Identifiable {
    let id: UUID
    let showName: String
    let episodes: Int
    let minutesEach: Int
    let sleepBudgetMinutes: Int
    let date: Date

    init(
        showName: String,
        episodes: Int,
        minutesEach: Int,
        sleepBudgetMinutes: Int,
        date: Date = Date()
    ) {
        id = UUID()
        self.showName = showName
        self.episodes = episodes
        self.minutesEach = minutesEach
        self.sleepBudgetMinutes = sleepBudgetMinutes
        self.date = date
    }

    var runtimeMinutes: Int { episodes * minutesEach }
    var remainingMinutes: Int { max(sleepBudgetMinutes - runtimeMinutes, 0) }
}

@main
struct OneMoreEpisodeApp: App {
    var body: some Scene { WindowGroup { OneMoreEpisodeView().dumbNativeEntry(scheme: "app14onemoreepisode") { _, _ in } } }
}

struct OneMoreEpisodeView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private static let emptyResult = "The remote is in your hand. History is being written."

    @AppStorage("oneMoreEpisode.episodes") private var episodes = 1.0
    @AppStorage("oneMoreEpisode.minutesEach") private var minutesEach = 45.0
    @AppStorage("oneMoreEpisode.sleepBudget") private var sleepBudgetHours = 8.0
    @AppStorage("oneMoreEpisode.showName") private var showName = ""
    @AppStorage("oneMoreEpisode.result") private var result = Self.emptyResult
    @AppStorage("oneMoreEpisode.history") private var storedHistory = "[]"

    @State private var history: [EpisodeForecast] = []
    @State private var hasLoaded = false
    @State private var showAllHistory = false
    @State private var showEraseConfirmation = false

    private let accent = CorpPalette.violet

    var body: some View {
        DumbShell(
            eyebrow: "STREAMING CONSEQUENCES",
            title: "One more episode?",
            subtitle: "A transparent trade-off calculator for bedtime bargaining.",
            accent: accent,
            personality: .chaotic
        ) {
            assumptionCard
            forecastEditor

            DumbAction(
                title: "Calculate & file tomorrow",
                accent: accent,
                systemImage: "moon.zzz.fill",
                action: calculateTomorrow
            )
            .accessibilityIdentifier("calculateTomorrowButton")

            DumbResult(
                text: result,
                accent: accent,
                systemImage: "play.tv.fill",
                reactionStyle: .bounce
            )
            .accessibilityIdentifier("episodeForecastResult")

            Button(action: resetCurrentForecast) {
                Label("Reset current forecast", systemImage: "arrow.counterclockwise")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(!hasCurrentForecast)
            .accessibilityIdentifier("resetEpisodeButton")

            historyCard

            Button {
                showEraseConfirmation = true
            } label: {
                Label("Erase every forecast", systemImage: "trash.fill")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(history.isEmpty && !hasCurrentForecast)
            .accessibilityIdentifier("eraseEpisodeDataButton")
        }
        .onAppear(perform: restoreHistory)
        .onChange(of: episodes) { _, _ in invalidateForecast() }
        .onChange(of: minutesEach) { _, _ in invalidateForecast() }
        .onChange(of: sleepBudgetHours) { _, _ in invalidateForecast() }
        .onChange(of: showName) { _, _ in invalidateForecast() }
        .confirmationDialog(
            "Erase the current forecast and complete history?",
            isPresented: $showEraseConfirmation,
            titleVisibility: .visible
        ) {
            Button("Confirm erase every forecast", role: .destructive, action: eraseAllData)
            Button("Keep negotiating", role: .cancel) {}
        } message: {
            Text("This erases every episode forecast. It cannot be undone.")
        }
    }

    private var assumptionCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 7) {
                DumbStatusPill(
                    "PUBLISHED ASSUMPTION",
                    systemImage: "equal.circle.fill",
                    accent: accent
                )
                Text("Pick your bedtime and episode length. We’ll show exactly how much sleep the next episode steals.")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CorpPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var forecastEditor: some View {
        DumbCard(accent: accent, isSelected: episodes >= 5) {
            VStack(alignment: .leading, spacing: 13) {
                Text("PROGRAM THE BAD IDEA")
                    .font(.caption2.weight(.black))
                    .tracking(1.2)
                    .foregroundStyle(CorpPalette.mutedInk)

                DumbField(
                    "Show name (optional)",
                    maxLength: 80,
                    text: $showName
                )

                DumbSlider(
                    title: "Episodes",
                    value: $episodes,
                    range: 1...8,
                    step: 1,
                    accent: accent
                )
                DumbSlider(
                    title: "Minutes per episode",
                    value: $minutesEach,
                    range: 15...120,
                    step: 5,
                    accent: accent
                )
                DumbSlider(
                    title: "Your sleep budget in hours",
                    value: $sleepBudgetHours,
                    range: 4...12,
                    step: 0.5,
                    accent: accent
                )
            }
        }
    }

    private var historyCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 11) {
                HStack {
                    Text("FORECAST ARCHIVE")
                        .font(.caption2.weight(.black))
                        .tracking(1.2)
                        .foregroundStyle(CorpPalette.mutedInk)
                    Spacer()
                    Text("\(history.count) filed")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .accessibilityIdentifier("episodeHistoryCount")
                        .accessibilityValue("\(history.count)")
                }

                if history.isEmpty {
                    Label("Tomorrow has no evidence yet.", systemImage: "moon.stars")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(CorpPalette.ink)
                        .accessibilityIdentifier("emptyEpisodeHistory")
                } else {
                    ForEach(visibleHistory) { forecast in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                DumbStatusPill(
                                    "\(forecast.runtimeMinutes) MIN WATCH",
                                    systemImage: "play.rectangle.fill",
                                    accent: accent
                                )
                                Spacer()
                                Text(forecast.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(CorpPalette.mutedInk)
                            }
                            Text(forecast.showName.isEmpty ? "Unnamed show" : forecast.showName)
                                .font(.headline.weight(.black))
                                .foregroundStyle(CorpPalette.ink)
                            Text("\(forecast.episodes) × \(forecast.minutesEach) min · \(formatMinutes(forecast.remainingMinutes)) budget left")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(CorpPalette.ink)
                            Button(role: .destructive) {
                                delete(forecast)
                            } label: {
                                Label("Delete episode forecast", systemImage: "trash")
                                    .font(.caption.weight(.black))
                            }
                            .accessibilityIdentifier("deleteEpisodeForecastButton")
                        }
                        .padding(.vertical, 3)
                    }

                    if history.count > 5 {
                        Button(showAllHistory ? "Show newest five" : "Browse all \(history.count)") {
                            withAnimation(reduceMotion ? nil : .snappy) {
                                showAllHistory.toggle()
                            }
                        }
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(accent)
                        .accessibilityIdentifier("toggleEpisodeHistoryButton")
                    }
                }
            }
        }
    }

    private var visibleHistory: [EpisodeForecast] {
        showAllHistory ? history : Array(history.prefix(5))
    }

    private var hasCurrentForecast: Bool {
        !showName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || episodes != 1
            || minutesEach != 45
            || sleepBudgetHours != 8
            || result != Self.emptyResult
    }

    private func calculateTomorrow() {
        let forecast = EpisodeForecast(
            showName: showName.trimmingCharacters(in: .whitespacesAndNewlines),
            episodes: Int(episodes),
            minutesEach: Int(minutesEach),
            sleepBudgetMinutes: Int((sleepBudgetHours * 60).rounded())
        )
        let impliedWake = forecast.remainingMinutes
        let regretLine: String
        if forecast.runtimeMinutes >= forecast.sleepBudgetMinutes {
            regretLine = "Tomorrow-you is filing a formal complaint. The chosen sleep budget is gone."
        } else if forecast.remainingMinutes < 360 {
            regretLine = "Tomorrow-you will negotiate with the alarm like it owes them money."
        } else {
            regretLine = "Tomorrow-you may survive, but the remote was definitely the villain."
        }
        result = """
        Watch time: \(formatMinutes(forecast.runtimeMinutes)).
        Sleep budget left: \(formatMinutes(forecast.remainingMinutes)) (~\(formatMinutes(impliedWake)) before a hypothetical wake-up).
        \(regretLine)
        """
        history.insert(forecast, at: 0)
        history = Array(history.prefix(20))
        persistHistory()
    }

    private func formatMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let remainder = minutes % 60
        if hours == 0 { return "\(remainder) min" }
        if remainder == 0 { return "\(hours) hr" }
        return "\(hours) hr \(remainder) min"
    }

    private func invalidateForecast() {
        guard result != Self.emptyResult else { return }
        result = "Inputs changed. Calculate a fresh tomorrow."
    }

    private func resetCurrentForecast() {
        episodes = 1
        minutesEach = 45
        sleepBudgetHours = 8
        showName = ""
        result = Self.emptyResult
    }

    private func delete(_ forecast: EpisodeForecast) {
        history.removeAll { $0.id == forecast.id }
        persistHistory()
    }

    private func eraseAllData() {
        history = []
        showAllHistory = false
        episodes = 1
        minutesEach = 45
        sleepBudgetHours = 8
        showName = ""
        result = Self.emptyResult
        persistHistory()
    }

    private func restoreHistory() {
        guard !hasLoaded else { return }
        hasLoaded = true
        guard
            let data = storedHistory.data(using: .utf8),
            let saved = try? JSONDecoder().decode([EpisodeForecast].self, from: data)
        else {
            return
        }
        history = saved.sorted { $0.date > $1.date }
    }

    private func persistHistory() {
        guard
            let data = try? JSONEncoder().encode(history),
            let value = String(data: data, encoding: .utf8)
        else {
            return
        }
        storedHistory = value
    }
}
