import SwiftUI
import DumbKit

@main
struct VibeMeterApp: App {
    var body: some Scene { WindowGroup { VibeMeterView().dumbNativeEntry(scheme: "app21vibemeter") { _, _ in } } }
}

struct VibeMeterView: View {
    @AppStorage("vibeMeter.room") private var room = ""
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
            personality: .chaotic,
            experience: .meter
        ) {
            DumbCard(accent: accent, isSelected: score > 60) {
                VStack(alignment: .leading, spacing: 16) {
                    DumbField("Room description (optional)", maxLength: 120, text: $room)
                    DumbSlider(title: "Plants", value: $plants, range: 0...10, step: 1, accent: CorpPalette.parkGreen)
                    DumbSlider(title: "Warm lamps", value: $lamps, range: 0...10, step: 1, accent: CorpPalette.sunshine)

                    HStack(spacing: 16) {
                        scoreGauge
                        VStack(alignment: .leading, spacing: 4) {
                            Text("VIBE SCORE")
                                .font(.caption2.weight(.black))
                                .tracking(1.1)
                                .foregroundStyle(accent)
                            Text("\(score)/100")
                                .font(.title2.weight(.black))
                                .foregroundStyle(CorpPalette.ink)
                                .contentTransition(.numericText())
                            Text(score > 60 ? "Shoe-removal territory" : "Email-address energy")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(CorpPalette.mutedInk)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
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
                room = ""
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

    private var scoreGauge: some View {
        ZStack {
            Circle()
                .stroke(accent.opacity(0.16), lineWidth: 10)
            Circle()
                .trim(from: 0, to: CGFloat(score) / 100)
                .stroke(accent, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(score)")
                .font(.title3.weight(.black))
                .foregroundStyle(accent)
                .contentTransition(.numericText())
        }
        .frame(width: 84, height: 84)
        .accessibilityHidden(true)
    }

    private var score: Int {
        min(100, Int(plants * 4 + lamps * 5))
    }

    private func measure() {
        let roomLabel = room.trimmingCharacters(in: .whitespacesAndNewlines)
        let roomPrefix = roomLabel.isEmpty ? "" : "\(roomLabel): "
        let verdict = score > 60
            ? "People will remove their shoes here."
            : "The room has an email address and no joy."
        result = "\(roomPrefix)Vibe score: \(score)/100. \(verdict)"
    }
}
