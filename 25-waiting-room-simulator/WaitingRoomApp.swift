import SwiftUI
import DumbKit

@main
struct WaitingRoomApp: App {
    var body: some Scene { WindowGroup { WaitingRoomView() } }
}

struct WaitingRoomView: View {
    @AppStorage("waitingRoom.minutes") private var minutes = 0.0
    @AppStorage("waitingRoom.result") private var result = "Your name will be called shortly. This is untrue."

    private let accent = CorpPalette.bathroomBlue

    var body: some View {
        DumbShell(
            eyebrow: "PATIENT WAITING SERVICES",
            title: "Waiting room simulator",
            subtitle: "No magazines. No answers. Just chairs.",
            accent: accent,
            personality: .office
        ) {
            DumbCard(accent: accent, isSelected: minutes > 45) {
                VStack(alignment: .leading, spacing: 10) {
                    DumbSlider(
                        title: "Simulated minutes waited",
                        value: $minutes,
                        range: 0...120,
                        step: 1,
                        accent: accent
                    )
                    Text("The clock advances five minutes each time you continue waiting.")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CorpPalette.mutedInk)
                }
            }
            .accessibilityIdentifier("waitingRoomInput")

            DumbAction(
                title: "Wait five more minutes",
                accent: accent,
                systemImage: "clock.arrow.circlepath",
                action: continueWaiting
            )
            .accessibilityIdentifier("continueWaitingButton")

            DumbResult(text: result, accent: accent, systemImage: "chair.lounge.fill", reactionStyle: .shake)

            Button {
                minutes = 0
                result = "Your name will be called shortly. This is untrue."
            } label: {
                Label("Leave the waiting room", systemImage: "figure.walk.depart")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .accessibilityIdentifier("resetWaitingRoomButton")
        }
    }

    private func continueWaiting() {
        minutes = min(minutes + 5, 120)
        result = minutes > 45
            ? "You have achieved waiting-room enlightenment."
            : "The receptionist has looked directly through you."
    }
}
