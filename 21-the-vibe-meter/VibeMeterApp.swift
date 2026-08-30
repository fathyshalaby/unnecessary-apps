import SwiftUI
import DumbKit

@main
struct VibeMeterApp: App {
    var body: some Scene { WindowGroup { VibeMeterView() } }
}

struct VibeMeterView: View {
    @AppStorage("vibeMeter.plants") private var plants = 2.0
    @AppStorage("vibeMeter.lamps") private var lamps = 3.0
    @AppStorage("vibeMeter.result") private var result = "The room has not yet been judged."

    private let accent = CorpPalette.violet

    var body: some View {
        DumbShell(
            eyebrow: "ATMOSPHERE REGULATION",
            title: "The vibe meter",
            subtitle: "A room can be fine and still have bad energy.",
            accent: accent,
            personality: .chaotic
        ) {
            DumbCard(accent: accent, isSelected: score > 60) {
                VStack(alignment: .leading, spacing: 16) {
                    DumbSlider(title: "Plants", value: $plants, range: 0...10, step: 1, accent: CorpPalette.parkGreen)
                    DumbSlider(title: "Warm lamps", value: $lamps, range: 0...10, step: 1, accent: CorpPalette.sunshine)
                    Text("Vibe score: \(score)/100")
                        .font(.title3.weight(.black))
                        .foregroundStyle(accent)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .accessibilityIdentifier("vibeInputs")

            DumbAction(
                title: "Measure the vibe",
                accent: accent,
                systemImage: "sparkles",
                action: measure
            )
            .accessibilityIdentifier("measureVibeButton")

            DumbResult(text: result, accent: accent, systemImage: "gauge.with.dots.needle.67percent", reactionStyle: .bounce)

            Button {
                plants = 2
                lamps = 3
                result = "The room has not yet been judged."
            } label: {
                Label("Reset the atmosphere", systemImage: "arrow.counterclockwise")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .accessibilityIdentifier("resetVibeButton")
        }
    }

    private var score: Int {
        min(100, Int(plants * 4 + lamps * 5))
    }

    private func measure() {
        let verdict = score > 60
            ? "People will remove their shoes here."
            : "The room has an email address and no joy."
        result = "Vibe score: \(score)/100. \(verdict)"
    }
}
