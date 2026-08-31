import SwiftUI
import DumbKit

private struct DramaEntry: Codable, Identifiable {
    let id: UUID
    let subject: String
    let bpm: Int
    let result: String
    let date: Date

    init(subject: String, bpm: Int, result: String, date: Date = Date()) {
        id = UUID()
        self.subject = subject
        self.bpm = bpm
        self.result = result
        self.date = date
    }
}

@main struct HeartRateEmailApp: App { var body: some Scene { WindowGroup { HeartRateEmailView().dumbNativeEntry(scheme: "app38heartrateemail") { _, _ in } } } }
struct HeartRateEmailView: View {
    private static let emptyResult = "The inbox is calm for now."

    @AppStorage("heartRateEmail.subject") private var subject = "Quick question"
    @AppStorage("heartRateEmail.bpm") private var bpm = 104.0
    @AppStorage("heartRateEmail.result") private var result = Self.emptyResult
    @AppStorage("heartRateEmail.history") private var storedHistory = "[]"

    @State private var history: [DramaEntry] = []
    @State private var hasLoaded = false
    @State private var showEraseConfirmation = false

    private let accent = CorpPalette.emergencyRed

    var body: some View {
        AppCanvas(accent: accent) {
            AppHeader(
                eyebrow: "INBOX DRAMA LOG",
                title: "Heart rate during email",
                subtitle: "A silly self-report, deliberately not a heart monitor.",
                accent: accent
            )

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

            Button(action: reset) {
            Label("Reset the inbox", systemImage: "arrow.counterclockwise")
            .font(.subheadline.weight(.black))
            .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(!hasCurrentDraft)
            .accessibilityIdentifier("resetHeartRateEmailButton")
            .accessibilityHint("Clears the current subject and result without deleting drama history.")

            historyCard

            Button {
            showEraseConfirmation = true
            } label: {
            Label("Erase drama history", systemImage: "trash.fill")
            .font(.subheadline.weight(.black))
            .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(history.isEmpty)
            .accessibilityIdentifier("eraseHeartRateHistoryButton")

            DumbNativeTip(
            "Share from Mail",
            detail: "Share an email subject from Mail to log inbox drama faster.",
            systemImage: "square.and.arrow.down",
            accent: accent
            )

        } bottomBar: {
            DumbAction(title: "Record the drama", accent: accent, systemImage: "heart.fill", action: recordDrama)
            .accessibilityIdentifier("recordEmailDramaButton")

            DumbResult(text: result, accent: accent, systemImage: "envelope.badge.fill", reactionStyle: .shake)

        }
        .onAppear {
            restoreHistory()
            if let shared = DumbSharedPayload.consume(for: .heartRate) {
                subject = String(shared.prefix(120))
            }
        }
        .confirmationDialog(
            "Erase every filed drama entry?",
            isPresented: $showEraseConfirmation,
            titleVisibility: .visible
        ) {
            Button("Confirm erase drama history", role: .destructive, action: eraseHistory)
            Button("Keep the log", role: .cancel) {}
        } message: {
            Text("This removes every saved inbox drama entry. It cannot be undone.")
        }
    }

    private var hasCurrentDraft: Bool {
        subject.trimmingCharacters(in: .whitespacesAndNewlines) != "Quick question"
            || bpm != 104
            || result != Self.emptyResult
    }

    private var historyCard: some View {
        DumbCard(accent: accent, isSelected: !history.isEmpty) {
            VStack(alignment: .leading, spacing: 11) {
                HStack {
                    Text("RECENT INBOX DRAMA")
                        .font(.caption2.weight(.black))
                        .tracking(1.2)
                        .foregroundStyle(CorpPalette.mutedInk)
                    Spacer()
                    Text("\(history.count) entries")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .accessibilityIdentifier("heartRateHistoryCount")
                        .accessibilityValue("\(history.count)")
                }

                if history.isEmpty {
                    Label("No inbox events have been logged yet.", systemImage: "envelope")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(CorpPalette.ink)
                        .accessibilityIdentifier("emptyHeartRateHistory")
                } else {
                    List {
                        ForEach(Array(history.prefix(5))) { entry in
                            historyRow(entry)
                                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                                .listRowSeparator(.visible)
                                .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: deleteHistoryEntries)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .scrollDisabled(true)
                    .frame(minHeight: CGFloat(min(history.count, 5)) * 96)
                }
            }
        }
    }

    private func historyRow(_ entry: DramaEntry) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                DumbStatusPill(
                    "\(entry.bpm) BPM",
                    systemImage: entry.bpm > 100 ? "heart.fill" : "heart",
                    accent: accent
                )
                Spacer()
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(CorpPalette.mutedInk)
            }
            Text(entry.subject)
                .font(.headline.weight(.black))
                .foregroundStyle(CorpPalette.ink)
            Text(entry.result)
                .font(.caption.weight(.semibold))
                .foregroundStyle(CorpPalette.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("heartRateHistoryEntry")
    }

    private func deleteHistoryEntries(at offsets: IndexSet) {
        history.remove(atOffsets: offsets)
        persistHistory()
    }

    private func recordDrama() {
        let cleanSubject = subject.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanSubject.isEmpty else {
            result = "No subject entered. The inbox has achieved emotional neutrality."
            return
        }
        let dramaResult = bpm > 100
            ? "\(cleanSubject) caused a notable inbox event. Close the laptop and look at a tree."
            : "\(cleanSubject) was processed without cinematic damage."
        result = dramaResult
        history.insert(
            DramaEntry(subject: cleanSubject, bpm: Int(bpm), result: dramaResult),
            at: 0
        )
        history = Array(history.prefix(30))
        persistHistory()
    }

    private func reset() {
        subject = "Quick question"
        bpm = 104
        result = Self.emptyResult
    }

    private func eraseHistory() {
        history = []
        persistHistory()
    }

    private func restoreHistory() {
        guard !hasLoaded else { return }
        hasLoaded = true
        guard
            let data = storedHistory.data(using: .utf8),
            let saved = try? JSONDecoder().decode([DramaEntry].self, from: data)
        else { return }
        history = saved.sorted { $0.date > $1.date }
    }

    private func persistHistory() {
        guard
            let data = try? JSONEncoder().encode(history),
            let value = String(data: data, encoding: .utf8)
        else { return }
        storedHistory = value
    }
}
