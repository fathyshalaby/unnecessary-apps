import SwiftUI
import FoundationModels
import DumbKit

#if os(iOS)
import UIKit
#endif

@main
struct ApologyDraftApp: App {
    var body: some Scene {
        WindowGroup { ApologyDraftView() }
    }
}

struct ApologyDraftView: View {
    @State private var crime = ""
    @State private var tone = "Sincere-ish"
    @State private var draft = "The apology department is standing by."
    @State private var copied = false
    @State private var isGenerating = false
    @State private var modelStatus = "The apology department is ready."
    @State private var activeGenerationID: UUID?

    private let accent = CorpPalette.warningRed
    private let tones = ["Sincere-ish", "Formal", "Text message", "Dramatic"]

    var body: some View {
        DumbShell(
            eyebrow: "MINOR CRIMES OFFICE",
            title: "Apology draft generator",
            subtitle: "For when the crime was tiny but the silence is now enormous.",
            accent: accent,
            personality: .dramatic
        ) {
            DumbCard(accent: accent, isSelected: !crime.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                VStack(alignment: .leading, spacing: 14) {
                    DumbField(
                        "What did you do?",
                        axis: .vertical,
                        maxLength: 180,
                        text: $crime
                    )

                    tonePicker

                    if crime.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text("Describe the tiny crime before the department can draft.")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CorpPalette.mutedInk)
                    }
                }
            }
            .accessibilityIdentifier("crimeEditor")

            DumbAction(
                title: isGenerating ? "Consulting the apology department…" : "Draft a \(tone.lowercased()) apology",
                accent: accent,
                systemImage: "pencil.and.scribble",
                isLoading: isGenerating,
                action: generateDraft
            )
            .disabled(isGenerating || crime.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .accessibilityIdentifier("generateApologyButton")

            DumbResult(
                text: draft,
                accent: accent,
                systemImage: copied ? "checkmark.circle.fill" : "doc.text.fill",
                reactionStyle: .stamp
            )
            .accessibilityIdentifier("apologyDraft")

            Text(modelStatus)
                .font(.caption.weight(.semibold))
                .foregroundStyle(CorpPalette.mutedInk)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("modelStatus")

            HStack(spacing: 12) {
                Button {
                    copyDraft()
                } label: {
                    Label(copied ? "Copied" : "Copy draft", systemImage: copied ? "checkmark" : "doc.on.doc")
                        .font(.subheadline.weight(.black))
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .foregroundStyle(accent)
                .buttonStyle(DumbPressStyle())
                .disabled(!hasGeneratedDraft)
                .accessibilityIdentifier("copyDraftButton")

                Button {
                    clearCrimeScene()
                } label: {
                    Image(systemName: "trash")
                        .font(.headline.weight(.black))
                        .frame(width: 48, height: 44)
                }
                .foregroundStyle(accent)
                .buttonStyle(DumbPressStyle())
                .disabled(crime.isEmpty && !hasGeneratedDraft)
                .accessibilityLabel("Clear apology")
                .accessibilityIdentifier("clearApologyButton")
            }
        }
    }

    private var tonePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("PICK THE VIBE")
                    .font(.caption2.weight(.black).monospaced())
                    .tracking(1.1)
                    .foregroundStyle(CorpPalette.mutedInk)
                Spacer()
                Text(tone.uppercased())
                    .font(.caption2.weight(.black).monospaced())
                    .foregroundStyle(accent)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(tones, id: \.self) { option in
                        Button {
                            tone = option
                            copied = false
                        } label: {
                            Label(option, systemImage: toneSymbol(option))
                                .font(.caption.weight(.black))
                                .padding(.horizontal, 12)
                                .frame(minHeight: 44)
                        }
                        .foregroundStyle(tone == option ? CorpPalette.actionInk : accent)
                        .background(tone == option ? accent : accent.opacity(0.09), in: Capsule())
                        .buttonStyle(DumbPressStyle())
                        .accessibilityLabel(option)
                        .accessibilityValue(tone == option ? "Selected" : "Not selected")
                    }
                }
            }
        }
        .accessibilityIdentifier("tonePicker")
    }

    private func toneSymbol(_ option: String) -> String {
        switch option {
        case "Formal": return "briefcase.fill"
        case "Text message": return "message.fill"
        case "Dramatic": return "theatermasks.fill"
        default: return "heart.fill"
        }
    }

    private var hasGeneratedDraft: Bool {
        draft != "The apology department is standing by."
    }

    private var shouldForceLocalFallback: Bool {
        ProcessInfo.processInfo.arguments.contains("-UITestingForceFallback")
    }

    private func generateDraft() {
        let cleanCrime = crime.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanCrime.isEmpty else {
            draft = "No crime entered. You are cleared pending further nonsense."
            copied = false
            modelStatus = "Nothing was sent anywhere; the apology department needs a crime."
            return
        }

        isGenerating = true
        copied = false
        let generationID = UUID()
        activeGenerationID = generationID
        modelStatus = "The apology department is drafting…"
        Task {
            let generated: String?
            if shouldForceLocalFallback {
                generated = nil
            } else if #available(iOS 26.0, *) {
                generated = await generateOnDeviceDraft(for: cleanCrime, tone: tone)
            } else {
                generated = nil
            }
            await MainActor.run {
                guard activeGenerationID == generationID else { return }
                if let generated {
                    draft = generated
                    modelStatus = "Draft approved by the apology department."
                } else {
                    draft = fallbackDraft(for: cleanCrime, tone: tone)
                    modelStatus = "The backup apology clerk took the case."
                }
                isGenerating = false
                activeGenerationID = nil
            }
        }
        Task {
            try? await Task.sleep(for: .seconds(12))
            await MainActor.run {
                guard activeGenerationID == generationID, isGenerating else { return }
                draft = fallbackDraft(for: cleanCrime, tone: tone)
                isGenerating = false
                activeGenerationID = nil
                modelStatus = "The backup apology clerk took the case."
            }
        }
    }

    private func fallbackDraft(for crime: String, tone: String) -> String {
        switch tone {
        case "Formal":
            return "Please accept my apology for \(crime). I recognize the inconvenience caused and will take reasonable steps to avoid a repeat occurrence."
        case "Text message":
            return "sorry about \(crime) 😬 genuinely my bad. i’ll try not to do it again."
        case "Dramatic":
            return "I accept full responsibility for \(crime). History will remember this moment, but I hope you can forgive me before dinner."
        default:
            return "I’m sorry for \(crime). I understand this created a small but real inconvenience. I will reflect briefly and try to do better, subject to snacks."
        }
    }

    @available(iOS 26.0, *)
    private func generateOnDeviceDraft(for crime: String, tone: String) async -> String? {
        guard SystemLanguageModel.default.isAvailable else { return nil }

        let session = LanguageModelSession(instructions: """
        You write short apologies for harmless everyday mistakes. Return only the apology,
        in the requested tone, in 1 to 3 sentences. Do not make legal admissions, threats,
        medical claims, or promises about things outside the writer's control. Keep it human,
        specific, and proportionate to the small crime.
        """)

        do {
            let response = try await session.respond(to: "Tone: \(tone). Tiny crime: \(crime)")
            let text = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
            return text.isEmpty ? nil : text
        } catch {
            return nil
        }
    }

    private func copyDraft() {
        #if os(iOS)
        UIPasteboard.general.string = draft
        #endif
        copied = true
    }

    private func clearCrimeScene() {
        crime = ""
        draft = "The apology department is standing by."
        copied = false
        isGenerating = false
        activeGenerationID = nil
        modelStatus = "The apology department is ready."
    }
}
