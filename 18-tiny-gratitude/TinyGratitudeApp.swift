import SwiftUI
import DumbKit

private struct GratitudeEntry: Codable, Identifiable {
    let id: UUID
    let text: String
    let date: Date
    let kind: String

    init(text: String, kind: String, date: Date = Date()) {
        id = UUID()
        self.text = text
        self.date = date
        self.kind = kind
    }

    private enum CodingKeys: String, CodingKey {
        case id, text, date, kind
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        date = try container.decode(Date.self, forKey: .date)
        kind = try container.decodeIfPresent(String.self, forKey: .kind) ?? "Unsorted tiny win"
    }
}

@main
struct TinyGratitudeApp: App {
    var body: some Scene {
        WindowGroup { TinyGratitudeView() }
    }
}

struct TinyGratitudeView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var entry = ""
    @State private var entries: [GratitudeEntry] = []
    @State private var result = "No tiny blessing recorded."
    @State private var hasLoaded = false
    @State private var kind = "Tiny comfort"
    @State private var showAllEntries = false
    @State private var showArchiveActions = false
    @AppStorage("tinyGratitude.entries") private var storedEntries = "[]"

    private let accent = CorpPalette.sky
    private let calendar = Calendar.current
    private let kinds = ["Tiny comfort", "Someone helped", "Something worked", "I showed up", "Other"]

    var body: some View {
        DumbShell(
            eyebrow: "MINOR BLESSINGS DEPARTMENT",
            title: "Tiny gratitude",
            subtitle: "Big gratitude is exhausting. Small gratitude is manageable.",
            accent: accent,
            personality: .optimistic
        ) {
            summaryCard
            editorCard

            DumbAction(
                title: "Archive this miracle",
                accent: accent,
                systemImage: "archivebox.fill",
                action: archiveEntry
            )
            .disabled(entry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .accessibilityIdentifier("archiveButton")

            DumbResult(
                text: result,
                accent: accent,
                systemImage: "sun.max.fill",
                reactionStyle: .stamp
            )
            .accessibilityIdentifier("gratitudeResult")

            archiveCard

            Button(action: resurfaceEntry) {
                Label("Resurface one tiny win", systemImage: "sparkles")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: DumbMetrics.minimumTapTarget)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(entries.isEmpty)
            .accessibilityIdentifier("resurfaceGratitudeButton")

            Button {
                showArchiveActions = true
            } label: {
                Label("Manage the tiny archive", systemImage: "archivebox.fill")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(entries.isEmpty)
            .accessibilityIdentifier("clearArchiveButton")
            .accessibilityHint("Opens controls for resurfacing or erasing saved entries.")
        }
        .onAppear(perform: restoreArchive)
        .confirmationDialog(
            "Tiny archive services",
            isPresented: $showArchiveActions,
            titleVisibility: .visible
        ) {
            Button("Resurface one tiny win", action: resurfaceEntry)
            Button("Erase gratitude archive", role: .destructive, action: clearArchive)
            Button("Keep the miracles", role: .cancel) {}
        } message: {
            Text("This erases every tiny win. It cannot be undone.")
        }
    }

    private var summaryCard: some View {
        DumbCard(accent: accent, isSelected: !entries.isEmpty) {
            HStack(spacing: 12) {
                summaryMetric(value: todayCount, label: "today")
                Divider()
                summaryMetric(value: entries.count, label: "saved")
                Divider()
                summaryMetric(value: uniqueDayCount, label: "days")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("gratitudeSummary")
        .accessibilityLabel("Tiny gratitude archive summary")
        .accessibilityValue("\(todayCount) today, \(entries.count) saved, \(uniqueDayCount) days")
    }

    private func summaryMetric(value: Int, label: String) -> some View {
        VStack(spacing: 3) {
            Text("\(value)")
                .font(.title2.weight(.black))
                .foregroundStyle(accent)
                .contentTransition(.numericText())
            Text(label.uppercased())
                .font(.caption2.weight(.black))
                .tracking(0.8)
                .foregroundStyle(CorpPalette.mutedInk)
        }
        .frame(maxWidth: .infinity)
    }

    private var editorCard: some View {
        DumbCard(accent: accent, isSelected: !entry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
            VStack(alignment: .leading, spacing: 12) {
                Text("FILE A MICRO-MIRACLE")
                    .font(.caption2.weight(.black))
                    .tracking(1.2)
                    .foregroundStyle(CorpPalette.mutedInk)

                Picker("What kind of tiny win?", selection: $kind) {
                    ForEach(kinds, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(.menu)
                .tint(accent)
                .accessibilityIdentifier("gratitudeKindPicker")

                DumbField(
                    "Gratitude entry",
                    axis: .vertical,
                    maxLength: 180,
                    text: $entry
                )
                Text("\(entry.count)/180")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(CorpPalette.mutedInk)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    private var archiveCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("TINY ARCHIVE")
                        .font(.caption2.weight(.black))
                        .tracking(1.2)
                        .foregroundStyle(CorpPalette.mutedInk)
                    Spacer()
                    Text("\(entries.count) saved")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .accessibilityIdentifier("gratitudeArchiveCount")
                        .accessibilityValue("\(entries.count)")
                }

                if entries.isEmpty {
                    Label("Nothing microscopic yet.", systemImage: "sun.horizon.fill")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(CorpPalette.ink)
                } else {
                    ForEach(visibleEntries) { savedEntry in
                        VStack(alignment: .leading, spacing: 7) {
                            HStack {
                                DumbStatusPill(
                                    savedEntry.kind.uppercased(),
                                    systemImage: "sparkles",
                                    accent: accent
                                )
                                Spacer()
                                Text(savedEntry.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(CorpPalette.mutedInk)
                            }
                            Text("“\(savedEntry.text)”")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(CorpPalette.ink)
                                .fixedSize(horizontal: false, vertical: true)
                            Button(role: .destructive) {
                                delete(savedEntry)
                            } label: {
                                Label("Delete tiny win", systemImage: "trash")
                                    .font(.caption.weight(.black))
                            }
                            .accessibilityIdentifier("deleteGratitudeButton")
                        }
                        .padding(.vertical, 3)
                    }

                    if entries.count > 5 {
                        Button(showAllEntries ? "Show newest five" : "Browse all \(entries.count)") {
                            withAnimation(reduceMotion ? nil : .snappy) {
                                showAllEntries.toggle()
                            }
                        }
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(accent)
                        .accessibilityIdentifier("toggleGratitudeHistoryButton")
                    }
                }
            }
        }
    }

    private var todayCount: Int {
        entries.filter { calendar.isDateInToday($0.date) }.count
    }

    private var uniqueDayCount: Int {
        Set(entries.map { calendar.startOfDay(for: $0.date) }).count
    }

    private var visibleEntries: [GratitudeEntry] {
        showAllEntries ? entries : Array(entries.prefix(5))
    }

    private func archiveEntry() {
        let cleanEntry = entry.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanEntry.isEmpty else { return }
        entries.insert(GratitudeEntry(text: cleanEntry, kind: kind), at: 0)
        entries = Array(entries.prefix(100))
        result = "Archived under \(kind.lowercased()): \(cleanEntry)."
        entry = ""
        persistArchive()
    }

    private func delete(_ savedEntry: GratitudeEntry) {
        entries.removeAll { $0.id == savedEntry.id }
        result = "One tiny win was removed from the jar."
        persistArchive()
    }

    private func resurfaceEntry() {
        guard let savedEntry = entries.randomElement() else { return }
        result = "Pocket miracle: \(savedEntry.text)"
    }

    private func clearArchive() {
        entries.removeAll()
        showAllEntries = false
        result = "The archive is empty. Even the small miracles have unionized."
        persistArchive()
    }

    private func restoreArchive() {
        guard !hasLoaded else { return }
        hasLoaded = true
        guard
            let data = storedEntries.data(using: .utf8),
            let saved = try? JSONDecoder().decode([GratitudeEntry].self, from: data)
        else {
            return
        }
        entries = saved.sorted { $0.date > $1.date }
    }

    private func persistArchive() {
        guard let data = try? JSONEncoder().encode(entries),
              let value = String(data: data, encoding: .utf8)
        else { return }
        storedEntries = value
    }
}
