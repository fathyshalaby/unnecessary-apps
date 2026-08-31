import SwiftUI
import DumbKit

private struct SnackPick: Codable, Identifiable {
    let id: UUID
    let name: String
    let date: Date

    init(name: String, date: Date = Date()) {
        id = UUID()
        self.name = name
        self.date = date
    }
}

@main
struct SnackRouletteApp: App {
    var body: some Scene {
        WindowGroup { SnackRouletteView().dumbNativeEntry(scheme: "app22snackroulette") { _, _ in } }
    }
}

struct SnackRouletteView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private static let defaultSnacks = ""

    @AppStorage("snackRoulette.snacks") private var snacks = Self.defaultSnacks
    @AppStorage("snackRoulette.result") private var storedResult = "The wheel is still."
    @AppStorage("snackRoulette.history") private var storedHistory = "[]"
    @State private var result = "The wheel is still."
    @State private var history: [SnackPick] = []
    @State private var hasLoaded = false
    @State private var showAllHistory = false
    @State private var showEraseConfirmation = false

    private let accent = CorpPalette.warningRed

    var body: some View {
        ZStack {
            CorpPalette.canvas.ignoresSafeArea()
            LinearGradient(
                colors: [accent.opacity(0.12), CorpPalette.canvas],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                AppHeader(
                    eyebrow: "PANTRY GAMBLING",
                    title: "Snack roulette",
                    subtitle: "A decision engine for an open cupboard.",
                    accent: accent
                )
                .padding(.horizontal, DumbSpacing.md)
                .padding(.top, DumbSpacing.sm)

                ScrollView {
                    VStack(spacing: DumbSpacing.md) {
                        DumbCard(accent: accent, isSelected: !snackChoices.isEmpty) {
                            VStack(alignment: .leading, spacing: 8) {
                                DumbField(
                                    "Comma-separated snacks",
                                    axis: .vertical,
                                    maxLength: 420,
                                    text: $snacks
                                )
                                Text("\(snackChoices.count) valid option\(snackChoices.count == 1 ? "" : "s") on the table")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(CorpPalette.mutedInk)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .accessibilityIdentifier("snackChoiceCount")
                                    .accessibilityValue("\(snackChoices.count)")
                            }
                        }

                        DumbResult(
                            text: result,
                            accent: accent,
                            systemImage: "circle.dotted.and.circle",
                            reactionStyle: .shake
                        )
                        .accessibilityIdentifier("snackResult")

                        if snackChoices.isEmpty {
                            Text("Enter at least one snack above to unlock the wheel.")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(CorpPalette.mutedInk)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        historyCard

                        Button {
                            showEraseConfirmation = true
                        } label: {
                            Label("Erase pantry & spin history", systemImage: "trash.fill")
                                .font(.subheadline.weight(.black))
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .foregroundStyle(accent)
                        .buttonStyle(DumbPressStyle())
                        .disabled(history.isEmpty && snacks.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .accessibilityIdentifier("clearSnackHistoryButton")
                    }
                    .padding(.horizontal, DumbSpacing.md)
                    .padding(.bottom, 120)
                }
                .scrollIndicators(.hidden)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                DumbAction(
                    title: snackChoices.isEmpty ? "Add snacks to spin" : "Spin the snack",
                    accent: accent,
                    systemImage: "shuffle",
                    action: spin
                )
                .disabled(snackChoices.isEmpty)
                .accessibilityIdentifier("spinSnackButton")
                .padding(.horizontal, DumbSpacing.md)
                .padding(.vertical, DumbSpacing.sm)
                .background(CorpPalette.canvas.opacity(0.96))
            }
        }
        .tint(accent)
        .environment(\.dumbExperienceStyle, .game)
        .onAppear(perform: restoreState)
        .onChange(of: snacks) { _, _ in
            if !history.isEmpty {
                result = "Pantry changed. Spin again for a current ruling."
                storedResult = result
            }
        }
        .confirmationDialog(
            "Erase the pantry and every saved spin?",
            isPresented: $showEraseConfirmation,
            titleVisibility: .visible
        ) {
            Button("Confirm erase the pantry and spin history", role: .destructive, action: eraseAllData)
            Button("Keep the snacks", role: .cancel) {}
        } message: {
            Text("This clears the pantry, latest ruling, and spin history.")
        }
    }

    private var snackChoices: [String] {
        var seen = Set<String>()
        return snacks
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .filter { seen.insert($0.lowercased()).inserted }
    }

    private var historyCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("RECENTLY CHOSEN")
                        .font(.caption2.weight(.black))
                        .tracking(1.2)
                        .foregroundStyle(CorpPalette.mutedInk)
                    Spacer()
                    Text("\(history.count) spins")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .accessibilityIdentifier("snackHistoryCount")
                        .accessibilityValue("\(history.count)")
                }

                if history.isEmpty {
                    Label("No snack has accepted its destiny yet.", systemImage: "questionmark.circle")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(CorpPalette.ink)
                } else {
                    ForEach(visibleHistory) { pick in
                        HStack(spacing: 10) {
                            Image(systemName: "circle.fill")
                                .font(.caption2)
                                .foregroundStyle(accent)
                                .accessibilityHidden(true)
                            Text(pick.name)
                                .font(.subheadline.weight(.black))
                                .foregroundStyle(CorpPalette.ink)
                            Spacer()
                            Text(pick.date.formatted(date: .omitted, time: .shortened))
                                .font(.caption.weight(.bold))
                                .foregroundStyle(CorpPalette.mutedInk)
                            Button(role: .destructive) {
                                delete(pick)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .accessibilityLabel("Delete snack spin")
                            .accessibilityIdentifier("deleteSnackPickButton")
                        }
                    }

                    if history.count > 5 {
                        Button(showAllHistory ? "Show newest five" : "Browse all \(history.count)") {
                            withAnimation(reduceMotion ? nil : .snappy) {
                                showAllHistory.toggle()
                            }
                        }
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(accent)
                        .accessibilityIdentifier("toggleSnackHistoryButton")
                    }
                }
            }
        }
    }

    private var visibleHistory: [SnackPick] {
        showAllHistory ? history : Array(history.prefix(5))
    }

    private func spin() {
        guard !snackChoices.isEmpty else {
            result = "No snacks entered. You have selected fasting by accident."
            storedResult = result
            return
        }

        let candidates = snackChoices.count > 1
            ? snackChoices.filter { $0 != history.first?.name }
            : snackChoices
        let choice = (candidates.isEmpty ? snackChoices : candidates).randomElement() ?? snackChoices[0]
        result = "The wheel has chosen: \(choice). Fate is nutritionally neutral."
        storedResult = result
        history.insert(SnackPick(name: choice), at: 0)
        history = Array(history.prefix(20))
        persistHistory()
    }

    private func delete(_ pick: SnackPick) {
        history.removeAll { $0.id == pick.id }
        result = "One spin was removed from the snack record."
        storedResult = result
        persistHistory()
    }

    private func eraseAllData() {
        snacks = ""
        history = []
        showAllHistory = false
        result = "The pantry and spin history are empty."
        storedResult = result
        persistHistory()
    }

    private func restoreState() {
        guard !hasLoaded else { return }
        hasLoaded = true
        result = storedResult
        guard
            let data = storedHistory.data(using: .utf8),
            let saved = try? JSONDecoder().decode([SnackPick].self, from: data)
        else {
            return
        }
        history = saved.sorted { $0.date > $1.date }
    }

    private func persistHistory() {
        guard let data = try? JSONEncoder().encode(history),
              let value = String(data: data, encoding: .utf8)
        else { return }
        storedHistory = value
    }
}
