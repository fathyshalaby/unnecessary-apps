import SwiftUI
import DumbKit

@main
struct WaitingRoomApp: App {
    var body: some Scene { WindowGroup { WaitingRoomView().dumbNativeEntry(scheme: "app25waitingroom") { _, _ in } } }
}

struct WaitingRoomView: View {
    @AppStorage("waitingRoom.minutes") private var minutes = 0.0
    @AppStorage("waitingRoom.result") private var result = "Your name will be called shortly. This is untrue."

    private let accent = CorpPalette.bathroomBlue

    var body: some View {
        AppCanvas(accent: accent) {
            AppHeader(
                eyebrow: "PATIENT WAITING SERVICES",
                title: "Waiting room simulator",
                subtitle: "No magazines. No answers. Just chairs.",
                accent: accent
            )

            DumbHeroMeter(
                progress: waitSeverityProgress,
                valueLabel: "\(Int(minutes)) min",
                title: "Wait severity",
                subtitle: waitSeverityLabel,
                accent: waitSeverityColor,
                systemImage: minutes > 45 ? "brain.head.profile" : "chair.lounge.fill",
                variant: .chairs,
                size: 100
            )
            .accessibilityIdentifier("waitingRoomHeroMeter")

            DumbCard(accent: accent, isSelected: minutes > 45) {
            VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
            Text("WAIT SEVERITY")
            .font(.caption2.weight(.black))
            .tracking(1.1)
            .foregroundStyle(accent)
            Text("\(Int(minutes)) min")
            .font(.title2.weight(.black))
            .foregroundStyle(CorpPalette.ink)
            .contentTransition(.numericText())
            Text(waitSeverityLabel)
            .font(.caption.weight(.bold))
            .foregroundStyle(CorpPalette.mutedInk)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            }

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

            Button {
            minutes = 0
            updateResult()
            } label: {
            Label("Leave the waiting room", systemImage: "figure.walk.depart")
            .font(.subheadline.weight(.black))
            .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .accessibilityIdentifier("resetWaitingRoomButton")

        } bottomBar: {
            DumbAction(
            title: "Wait five more minutes",
            accent: accent,
            systemImage: "clock.arrow.circlepath",
            action: continueWaiting
            )
            .accessibilityIdentifier("continueWaitingButton")

            DumbResult(text: result, accent: accent, systemImage: "chair.lounge.fill", reactionStyle: .shake)

        }
        .onChange(of: minutes) { _, _ in
            updateResult()
        }
    }

    private var waitSeverityProgress: CGFloat {
        CGFloat(min(max(minutes / 120, 0), 1))
    }

    private var waitSeverityColor: Color {
        minutes > 45 ? CorpPalette.warningRed : accent
    }

    private var waitSeverityLabel: String {
        switch minutes {
        case 0..<15: return "Mild inconvenience"
        case 15..<45: return "Existential drift"
        default: return "Enlightenment achieved"
        }
    }

    private func continueWaiting() {
        minutes = min(minutes + 5, 120)
    }

    private func updateResult() {
        result = minutes > 45
            ? "You have achieved waiting-room enlightenment."
            : minutes > 0
                ? "The receptionist has looked directly through you."
                : "Your name will be called shortly. This is untrue."
    }
}
