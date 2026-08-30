import SwiftUI
import DumbKit

@main
struct HumanGPSApp: App {
    var body: some Scene { WindowGroup { HumanGPSView() } }
}

struct HumanGPSView: View {
    @AppStorage("humanGPS.landmark") private var landmark = "the bakery"
    @AppStorage("humanGPS.direction") private var direction = "Face the large thing."

    private let accent = CorpPalette.bathroomBlue

    var body: some View {
        DumbShell(
            eyebrow: "OUTSIDE COORDINATION",
            title: "Human GPS",
            subtitle: "Because “I’m outside” is not a coordinate.",
            accent: accent,
            personality: .optimistic
        ) {
            DumbCard(accent: accent, isSelected: !landmark.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                VStack(alignment: .leading, spacing: 8) {
                    DumbField("Nearby landmark", maxLength: 120, text: $landmark)
                    Text("Describe what you can see. Human directions are strongly encouraged.")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CorpPalette.mutedInk)
                }
            }
            .accessibilityIdentifier("humanGPSInput")

            DumbAction(
                title: "Generate instructions",
                accent: accent,
                systemImage: "location.north.fill",
                action: generateInstructions
            )
            .accessibilityIdentifier("generateDirectionsButton")

            DumbResult(text: direction, accent: accent, systemImage: "figure.walk", reactionStyle: .bounce)

            Button {
                landmark = "the bakery"
                direction = "Face the large thing."
            } label: {
                Label("Reset the coordinate", systemImage: "arrow.counterclockwise")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .accessibilityIdentifier("resetHumanGPSButton")
        }
    }

    private func generateInstructions() {
        let destination = landmark.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "the nearest landmark" : landmark
        direction = "Face \(destination). Walk until you see a person looking at their phone like they have also been abandoned."
    }
}
