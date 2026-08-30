import SwiftUI
import DumbKit

private struct FogMatch: Identifiable {
    let term: String
    let count: Int

    var id: String { term }
}

private struct EmailAnalysis {
    let words: Int
    let sentences: Int
    let paragraphs: Int
    let fogMatches: [FogMatch]
    let longSentences: Int
    let hasExplicitAsk: Bool
    let hasDeadline: Bool

    var fogMarkers: Int {
        fogMatches.reduce(0) { $0 + $1.count }
    }

    var averageSentenceLength: Int {
        max(1, Int(round(Double(words) / Double(sentences))))
    }

    var clarityScore: Int {
        var score = 100
        score -= min(35, fogMarkers * 7)
        score -= min(25, max(0, averageSentenceLength - 18) * 2)
        score -= min(16, longSentences * 8)
        if words > 100 && paragraphs == 1 { score -= 10 }
        if words >= 15 && !hasExplicitAsk { score -= 10 }
        return max(0, score)
    }

    var verdict: String {
        if clarityScore >= 85 {
            return "A real email. Suspiciously direct."
        }
        if clarityScore < 60 {
            return "Mostly corporate weather. Find the one actual sentence."
        }
        return "Technically an email. Trim a little fog before sending."
    }

    var recommendations: [String] {
        var items: [String] = []
        if !fogMatches.isEmpty {
            let terms = fogMatches.prefix(4).map(\.term).joined(separator: ", ")
            items.append("Cut or justify these phrases: \(terms).")
        }
        if longSentences > 0 || averageSentenceLength > 22 {
            items.append("Split the longest sentence so one sentence carries one job.")
        }
        if words >= 15 && !hasExplicitAsk {
            items.append("Name the action you need: reply, approve, send, choose, or confirm.")
        }
        if hasExplicitAsk && !hasDeadline {
            items.append("If timing matters, add a real deadline instead of implied urgency.")
        }
        if words > 180 {
            items.append("Move background detail below the request or into an attachment.")
        }
        if items.isEmpty {
            items.append("No obvious surgery required. Send it before a committee finds it.")
        }
        return items
    }
}

@main
struct RealEmailApp: App {
    var body: some Scene {
        WindowGroup { RealEmailView().dumbNativeEntry(scheme: "app20realemail") { _, _ in } }
    }
}

struct RealEmailView: View {
    private static let fogTerms = [
        "just", "actually", "really", "very", "basically", "moving forward",
        "at this point", "in order to", "please note", "as per", "circle back",
        "touch base", "synergy", "bandwidth", "leverage", "robust", "alignment"
    ]

    @State private var email = ""
    @State private var result = "No email means no problem. Yet."
    @State private var analysis: EmailAnalysis?

    private let accent = CorpPalette.bathroomBlue

    var body: some View {
        DumbShell(
            eyebrow: "INBOX FORENSICS",
            title: "Corporate fog detector",
            subtitle: "A clarity estimate for bloated paragraphs—not truth detection or inbox verification.",
            accent: accent,
            personality: .office
        ) {
            Text("Analysis stays on this device and clears when you leave.")
                .font(.caption.weight(.bold))
                .foregroundStyle(CorpPalette.mutedInk)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(accent.opacity(0.1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .accessibilityIdentifier("emailSessionBanner")

            editorCard

            DumbAction(
                title: "Perform email autopsy",
                accent: accent,
                systemImage: "stethoscope",
                action: analyze
            )
            .disabled(email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .accessibilityIdentifier("analyzeEmailButton")
            .accessibilityHint("Checks the current text against the visible writing rules.")

            DumbResult(
                text: result,
                accent: accent,
                systemImage: "envelope.badge.fill",
                reactionStyle: .shake
            )
            .accessibilityIdentifier("emailVerdict")

            if let analysis {
                metricsCard(analysis)
            }

            Button {
                clearEvidence()
            } label: {
                Label("Clear email evidence", systemImage: "eraser.fill")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(email.isEmpty && analysis == nil)
            .accessibilityIdentifier("clearEmailButton")
            .accessibilityHint("Removes the pasted email from this screen.")

            DumbNativeTip(
                "Share from Mail",
                detail: "Use the share sheet in Mail or Notes to send text here for a fog autopsy.",
                systemImage: "square.and.arrow.down",
                accent: accent
            )
        }
        .onAppear {
            if let shared = DumbSharedPayload.consume(for: .realEmail) {
                email = shared
            }
        }
        .onDisappear {
            clearEvidence()
        }
    }

    private var editorCard: some View {
        DumbCard(accent: accent, isSelected: !email.isEmpty) {
            VStack(alignment: .leading, spacing: 8) {
                Text("EMAIL EVIDENCE")
                    .font(.caption2.weight(.black))
                    .tracking(1.2)
                    .foregroundStyle(CorpPalette.mutedInk)

                ZStack(alignment: .topLeading) {
                    TextEditor(text: $email)
                        .frame(minHeight: 150)
                        .scrollContentBackground(.hidden)
                        .padding(8)
                        .background(CorpPalette.canvas, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                        .accessibilityLabel("Email evidence")
                        .accessibilityHint("Paste or type up to 5,000 characters to inspect.")
                        .onChange(of: email) { _, newValue in
                            if newValue.count > 5_000 {
                                email = String(newValue.prefix(5_000))
                                return
                            }
                            if analysis != nil {
                                analysis = nil
                                result = "Evidence changed. Run a fresh autopsy."
                            }
                        }

                    if email.isEmpty {
                        Text("Paste the suspicious email here…")
                            .font(.body.weight(.medium))
                            .foregroundStyle(CorpPalette.mutedInk.opacity(0.7))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }
                }

                HStack(spacing: 8) {
                    Label("No inbox snooping", systemImage: "eye.slash.fill")
                    Spacer()
                    Text("\(email.count)/5000")
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(CorpPalette.mutedInk)
            }
        }
        .accessibilityIdentifier("emailEditor")
    }

    @ViewBuilder
    private func metricsCard(_ analysis: EmailAnalysis) -> some View {
        DumbCard(accent: accent, isSelected: analysis.fogMarkers == 0) {
            VStack(alignment: .leading, spacing: 14) {
                Text("AUTOPSY REPORT")
                    .font(.caption2.weight(.black))
                    .tracking(1.2)
                    .foregroundStyle(CorpPalette.mutedInk)
                    .accessibilityIdentifier("emailMetrics")

                HStack(spacing: 10) {
                    metric("\(analysis.words)", label: "WORDS")
                    metric("\(analysis.sentences)", label: "SENTENCES")
                    metric("\(analysis.fogMarkers)", label: "FOG MARKERS")
                }

                Text("Average sentence: \(analysis.averageSentenceLength) words · \(analysis.paragraphs) paragraph\(analysis.paragraphs == 1 ? "" : "s")")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CorpPalette.mutedInk)

                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(analysis.clarityScore)")
                            .font(.system(.largeTitle, design: .rounded).weight(.black))
                            .foregroundStyle(accent)
                            .contentTransition(.numericText())
                        Text("CLARITY / 100")
                            .font(.caption2.weight(.black))
                            .foregroundStyle(CorpPalette.mutedInk)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Clarity score")
                    .accessibilityValue("\(analysis.clarityScore) out of 100")
                    .accessibilityIdentifier("emailClarityScore")

                    Spacer()

                    VStack(alignment: .trailing, spacing: 5) {
                        Label(analysis.hasExplicitAsk ? "ASK FOUND" : "ASK MISSING", systemImage: analysis.hasExplicitAsk ? "checkmark.circle.fill" : "questionmark.circle")
                        Label(analysis.hasDeadline ? "TIME FOUND" : "NO DEADLINE", systemImage: analysis.hasDeadline ? "calendar.badge.checkmark" : "calendar")
                    }
                    .font(.caption2.weight(.black))
                    .foregroundStyle(CorpPalette.mutedInk)
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("emailActionSignals")
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("FOUND PHRASES")
                        .font(.caption2.weight(.black))
                        .tracking(1)
                        .foregroundStyle(CorpPalette.mutedInk)
                    Text(fogSummary(analysis))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(CorpPalette.ink)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Found fog phrases")
                .accessibilityValue(fogSummary(analysis))
                .accessibilityIdentifier("emailFogTerms")
            }
        }

        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 10) {
                Text("SURGERY PLAN")
                    .font(.caption2.weight(.black))
                    .tracking(1.2)
                    .foregroundStyle(CorpPalette.mutedInk)

                ForEach(Array(analysis.recommendations.enumerated()), id: \.offset) { index, recommendation in
                    HStack(alignment: .top, spacing: 9) {
                        Text("\(index + 1)")
                            .font(.caption.weight(.black))
                            .foregroundStyle(.white)
                            .frame(width: 22, height: 22)
                            .background(accent, in: Circle())
                        Text(recommendation)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(CorpPalette.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("emailRecommendations")
    }

    private func metric(_ value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(.title3.weight(.black))
                .foregroundStyle(accent)
                .contentTransition(.numericText())
            Text(label)
                .font(.caption2.weight(.black))
                .foregroundStyle(CorpPalette.mutedInk)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private func fogSummary(_ analysis: EmailAnalysis) -> String {
        guard !analysis.fogMatches.isEmpty else {
            return "None from the official checklist."
        }
        return analysis.fogMatches
            .map { $0.count == 1 ? $0.term : "\($0.term) ×\($0.count)" }
            .joined(separator: " · ")
    }

    private func analyze() {
        let cleaned = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else {
            analysis = nil
            result = "No body detected. A perfect email."
            return
        }

        let tokens = Self.tokens(in: cleaned)
        let sentenceWordCounts = cleaned
            .split { $0 == "." || $0 == "!" || $0 == "?" || $0 == "\n" }
            .map { Self.tokens(in: String($0)).count }
            .filter { $0 > 0 }
        let matches = Self.fogTerms.compactMap { term -> FogMatch? in
            let count = Self.countPhrase(term, in: tokens)
            return count > 0 ? FogMatch(term: term, count: count) : nil
        }
        let explicitAskTerms = ["approve", "can", "choose", "complete", "confirm", "could", "please", "reply", "review", "send", "share"]
        let deadlineTerms = ["by", "deadline", "today", "tomorrow", "monday", "tuesday", "wednesday", "thursday", "friday"]
        let report = EmailAnalysis(
            words: tokens.count,
            sentences: max(1, sentenceWordCounts.count),
            paragraphs: Self.paragraphCount(in: cleaned),
            fogMatches: matches,
            longSentences: sentenceWordCounts.filter { $0 > 24 }.count,
            hasExplicitAsk: cleaned.contains("?") || tokens.contains(where: explicitAskTerms.contains),
            hasDeadline: tokens.contains(where: deadlineTerms.contains)
        )
        analysis = report
        result = report.verdict
    }

    private static func tokens(in text: String) -> [String] {
        text.lowercased()
            .split { !$0.isLetter && !$0.isNumber }
            .map(String.init)
    }

    private static func countPhrase(_ phrase: String, in tokens: [String]) -> Int {
        let phraseTokens = Self.tokens(in: phrase)
        guard !phraseTokens.isEmpty, tokens.count >= phraseTokens.count else { return 0 }

        return (0...(tokens.count - phraseTokens.count)).reduce(into: 0) { count, start in
            let end = start + phraseTokens.count
            if Array(tokens[start..<end]) == phraseTokens {
                count += 1
            }
        }
    }

    private static func paragraphCount(in text: String) -> Int {
        let normalized = text.replacingOccurrences(of: "\r\n", with: "\n")
        var count = 0
        var insideParagraph = false
        for line in normalized.split(separator: "\n", omittingEmptySubsequences: false) {
            let isBlank = line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            if isBlank {
                insideParagraph = false
            } else if !insideParagraph {
                count += 1
                insideParagraph = true
            }
        }
        return max(1, count)
    }

    private func clearEvidence() {
        email = ""
        analysis = nil
        result = "No email means no problem. Yet."
    }
}
