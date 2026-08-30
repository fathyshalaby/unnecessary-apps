import SwiftUI
import DumbKit

@main struct HeartRateEmailApp: App { var body: some Scene { WindowGroup { HeartRateEmailView() } } }
struct HeartRateEmailView: View {
    @AppStorage("heartRateEmail.subject") private var subject = "Quick question"
    @AppStorage("heartRateEmail.bpm") private var bpm = 104.0
    @AppStorage("heartRateEmail.result") private var result = "The inbox is calm for now."

    private let accent = CorpPalette.emergencyRed

    var body: some View {
        DumbShell(
            eyebrow: "INBOX PHYSIOLOGY THEATRE",
            title: "Heart rate during email",
            subtitle: "A silly self-report, deliberately not a heart monitor.",
            accent: accent,
            personality: .dramatic
        ) {
            DumbCard(accent: accent) {
                VStack(alignment: .leading, spacing: 14) {
                    DumbStatusPill("MANUAL ON PURPOSE", systemImage: "hand.raised.fill", accent: accent)
                    DumbField("Email subject", maxLength: 120, text: $subject)
                    DumbSlider(title: "Reported heart rate (bpm)", value: $bpm, range: 40...180, step: 1, accent: accent)
                    Text("Rate the inbox drama yourself. This app does not read, monitor, or interpret heart-rate data, and the number is not health advice.")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .accessibilityIdentifier("heartRateEmailInputs")

            DumbAction(title: "Record the drama", accent: accent, systemImage: "heart.fill", action: recordDrama)
                .accessibilityIdentifier("recordEmailDramaButton")

            DumbResult(text: result, accent: accent, systemImage: "envelope.badge.fill", reactionStyle: .shake)

            Button(action: reset) {
                Label("Reset the inbox", systemImage: "arrow.counterclockwise")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .accessibilityIdentifier("resetHeartRateEmailButton")
        }
    }

    private func recordDrama() {
        let cleanSubject = subject.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanSubject.isEmpty else {
            result = "No subject entered. The inbox has achieved emotional neutrality."
            return
        }
        result = bpm > 100
            ? "\(cleanSubject) caused a notable inbox event. Close the laptop and look at a tree."
            : "\(cleanSubject) was processed without cinematic damage."
    }

    private func reset() {
        subject = "Quick question"
        bpm = 104
        result = "The inbox is calm for now."
    }
}
