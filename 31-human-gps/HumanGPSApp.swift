import SwiftUI
import DumbKit

@main
struct HumanGPSApp: App {
    var body: some Scene { WindowGroup { HumanGPSView() } }
}

struct HumanGPSView: View {
    private static let emptyDirection = "Enter a landmark and generate instructions."

    @AppStorage("humanGPS.landmark") private var landmark = ""
    @AppStorage("humanGPS.direction") private var direction = Self.emptyDirection

    private let accent = CorpPalette.bathroomBlue

    var body: some View {
        DumbShell(
            eyebrow: "OUTSIDE COORDINATION",
            title: "Human GPS",
            subtitle: "Because “I'm outside” is not a coordinate.",
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
                landmark = ""
                direction = Self.emptyDirection
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
        let destination = landmark.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !destination.isEmpty else {
            direction = "No landmark entered. The GPS cannot navigate vibes alone."
            return
        }

        let lowered = destination.lowercased()
        let body: String
        if lowered.contains("bakery") || lowered.contains("boulangerie") || lowered.contains("café") || lowered.contains("cafe") {
            body = "Face \(destination). Walk toward the smell of bread and regret. Turn when you see someone holding a pastry like it is evidence."
        } else if lowered.contains("station") || lowered.contains("metro") || lowered.contains("train") || lowered.contains("bus") {
            body = "Face \(destination). Follow the crowd that looks late on purpose. If you hear an announcement, ignore it and keep walking."
        } else if lowered.contains("park") || lowered.contains("garden") || lowered.contains("square") {
            body = "Face \(destination). Walk past the bench where someone is reading the same page for twenty minutes. Green things mean you are close."
        } else if lowered.contains("shop") || lowered.contains("store") || lowered.contains("market") {
            body = "Face \(destination). Walk until the window display makes you question your budget. The entrance is probably behind someone on their phone."
        } else if lowered.contains("church") || lowered.contains("cathedral") || lowered.contains("temple") {
            body = "Face \(destination). Walk toward the tallest quiet building. If bells happen, you are either close or spiritually lost."
        } else {
            body = "Face \(destination). Walk until you see a person looking at their phone like they have also been abandoned."
        }
        direction = body
    }
}
