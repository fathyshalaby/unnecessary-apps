import SwiftUI
import DumbKit

@main struct LabTranslatorApp: App { var body: some Scene { WindowGroup { LabTranslatorView() } } }
struct LabTranslatorView: View {
    @AppStorage("labTranslator.marker") private var marker = "LDL cholesterol"
    @AppStorage("labTranslator.value") private var value = ""
    @AppStorage("labTranslator.result") private var result = "Enter a marker and value. Bring the result to a qualified clinician."

    private let accent = CorpPalette.bathroomBlue

    var body: some View {
        DumbShell(
            eyebrow: "LAB RESULT EXPLAINER",
            title: "Explain one lab result.",
            subtitle: "Educational context only. Your lab’s reference range and your clinician matter.",
            accent: accent,
            personality: .office
        ) {
            DumbCard(accent: accent) {
                VStack(alignment: .leading, spacing: 14) {
                    DumbField("Marker name", maxLength: 100, text: $marker)
                    DumbField("Value and unit", maxLength: 100, text: $value)
                    Text("Use this to prepare questions for your clinician. It does not interpret results or diagnose anything.")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CorpPalette.mutedInk)
                }
            }
            .accessibilityIdentifier("labTranslatorInputs")

            DumbAction(title: "Explain cautiously", accent: accent, systemImage: "cross.case.fill", action: explainCautiously)
                .accessibilityIdentifier("explainLabResultButton")

            DumbResult(text: result, accent: accent, systemImage: "stethoscope", reactionStyle: .stamp)

            Text("Not medical advice. Do not change medication or supplements based on this app. Bring the original report and its reference range to a qualified clinician.")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(CorpPalette.mutedInk)

            Button(action: reset) {
                Label("Reset the report", systemImage: "arrow.counterclockwise")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .accessibilityIdentifier("resetLabTranslatorButton")
        }
    }

    private func explainCautiously() {
        let cleanMarker = marker.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanMarker.isEmpty, !cleanValue.isEmpty else {
            result = "Enter both a marker and value. Bring the original report to a qualified clinician."
            return
        }
        result = "\(cleanMarker): \(cleanValue). This marker can have many interpretations depending on context. Question for your clinician: ‘What does this result mean for me, and should we repeat or investigate it?’"
    }

    private func reset() {
        marker = "LDL cholesterol"
        value = ""
        result = "Enter a marker and value. Bring the result to a qualified clinician."
    }
}
