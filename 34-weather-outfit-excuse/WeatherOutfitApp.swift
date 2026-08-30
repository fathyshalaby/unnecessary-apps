import SwiftUI
import DumbKit

@main struct WeatherOutfitApp: App { var body: some Scene { WindowGroup { WeatherOutfitView().dumbNativeEntry(scheme: "app34weatheroutfit") { _, _ in } } } }
struct WeatherOutfitView: View {
    @AppStorage("weatherOutfit.outfit") private var outfit = ""
    @AppStorage("weatherOutfit.temperature") private var temperature = 14.0
    @AppStorage("weatherOutfit.excuse") private var excuse = "No excuse prepared."

    private let accent = CorpPalette.bathroomBlue

    var body: some View {
        DumbShell(
            eyebrow: "OUTFIT DEFENSE SERVICES",
            title: "Weather outfit excuse",
            subtitle: "The forecast cannot cross-examine you.",
            accent: accent,
            personality: .optimistic
        ) {
            DumbCard(accent: accent) {
                VStack(alignment: .leading, spacing: 10) {
                    DumbStatusPill(
                        "MANUAL TEMPERATURE ONLY · NO LIVE WEATHER DATA",
                        systemImage: "hand.raised.fill",
                        accent: accent
                    )
                    DumbField("Your outfit", maxLength: 80, text: $outfit)
                    DumbSlider(title: "Temperature (°C)", value: $temperature, range: -10...35, step: 1, accent: accent)
                    Text("Enter the temperature outside. Then blame the weather with confidence.")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CorpPalette.mutedInk)
                }
            }
            .accessibilityIdentifier("weatherOutfitInputs")

            DumbAction(title: "Generate defense", accent: accent, systemImage: "sun.max.fill", action: generateDefense)
                .accessibilityIdentifier("generateOutfitDefenseButton")

            DumbResult(text: excuse, accent: accent, systemImage: "cloud.sun.fill", reactionStyle: .bounce)

            Button(action: reset) {
                Label("Reset the forecast", systemImage: "arrow.counterclockwise")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .accessibilityIdentifier("resetWeatherOutfitButton")
        }
    }

    private func generateDefense() {
        let cleanOutfit = outfit.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanOutfit.isEmpty else {
            excuse = "No outfit entered. The defense has no clothes to work with."
            return
        }
        let reason = temperature < 10
            ? "layers are a form of architecture"
            : temperature > 25
                ? "the sun demanded it"
                : "the weather forecast gave mixed signals and I chose optimism"
        excuse = "I wore the \(cleanOutfit) because \(reason)."
    }

    private func reset() {
        outfit = ""
        temperature = 14
        excuse = "No excuse prepared."
    }
}
