import SwiftUI
import DumbKit

private struct FridgeItem: Codable, Identifiable {
    let id: UUID
    var name: String
    var quantity: Int
    let addedDate: Date
    var useByDate: Date?

    init(
        name: String,
        quantity: Int,
        addedDate: Date = Date(),
        useByDate: Date?
    ) {
        id = UUID()
        self.name = name
        self.quantity = quantity
        self.addedDate = addedDate
        self.useByDate = useByDate
    }
}

struct FridgeWitnessView: View {
    private static let emptyStatement = "The fridge has no user-filed evidence yet."

    @AppStorage("fridgeWitness.items") private var storedItems = "[]"
    @AppStorage("fridgeWitness.statement") private var statement = Self.emptyStatement

    @State private var items: [FridgeItem] = []
    @State private var itemName = ""
    @State private var quantity = 1.0
    @State private var includesUseBy = true
    @State private var useByDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var hasLoaded = false
    @State private var showEraseConfirmation = false

    private let accent = CorpPalette.parkGreen

    var body: some View {
        AppCanvas(accent: accent) {
            AppHeader(
                eyebrow: "CASE FILE 0042",
                title: "The fridge is a witness.",
                subtitle: "An inventory for the food you actually put there.",
                accent: accent
            )

            boundaryCard
            summaryCard
            evidenceEditor

            inventoryCard

            Button {
                showEraseConfirmation = true
            } label: {
                Label("Erase the inventory", systemImage: "trash.fill")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(items.isEmpty && statement == Self.emptyStatement)
            .accessibilityIdentifier("eraseFridgeDataButton")

        } bottomBar: {
            DumbAction(
                title: "File fridge evidence",
                accent: accent,
                systemImage: "archivebox.fill",
                action: addItem
            )
            .disabled(itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .accessibilityIdentifier("fileFridgeEvidenceButton")

            DumbResult(
                text: statement,
                accent: accent,
                systemImage: "quote.bubble.fill",
                reactionStyle: .shake
            )
            .accessibilityIdentifier("fridgeWitnessStatement")

        }
        .onAppear(perform: restoreInventory)
        .confirmationDialog(
            "Erase the complete inventory?",
            isPresented: $showEraseConfirmation,
            titleVisibility: .visible
        ) {
            Button("Confirm erase the inventory", role: .destructive, action: eraseAllData)
            Button("Keep the evidence", role: .cancel) {}
        } message: {
            Text("This clears every fridge item and the current witness statement.")
        }
    }

    private var boundaryCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 7) {
                DumbStatusPill(
                    "YOU SET THE DATES",
                    systemImage: "calendar.badge.exclamationmark",
                    accent: accent
                )
                Text("Use the package date as your reminder. If food seems questionable, trust the label and your senses—not a cartoon fridge.")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CorpPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var summaryCard: some View {
        DumbCard(accent: accent, isSelected: !items.isEmpty) {
            HStack(spacing: 10) {
                summaryMetric(value: items.count, label: "types")
                Divider()
                summaryMetric(value: totalUnits, label: "units")
                Divider()
                summaryMetric(value: attentionCount, label: "attention")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("fridgeInventorySummary")
        .accessibilityLabel("Fridge inventory summary")
        .accessibilityValue("\(items.count) item types, \(totalUnits) units, \(attentionCount) need date attention")
    }

    private func summaryMetric(value: Int, label: String) -> some View {
        VStack(spacing: 3) {
            Text("\(value)")
                .font(.title2.weight(.black))
                .foregroundStyle(accent)
                .contentTransition(.numericText())
            Text(label.uppercased())
                .font(.caption2.weight(.black))
                .tracking(0.7)
                .foregroundStyle(CorpPalette.mutedInk)
        }
        .frame(maxWidth: .infinity)
    }

    private var evidenceEditor: some View {
        DumbCard(accent: accent, isSelected: !itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    Text("FILE REAL EVIDENCE")
                        .font(.caption2.weight(.black))
                        .tracking(1.2)
                        .foregroundStyle(CorpPalette.mutedInk)
                    Spacer()
                    Image(systemName: itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "lightbulb" : "lightbulb.max.fill")
                        .font(.title3.weight(.black))
                        .foregroundStyle(itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? accent.opacity(0.35) : CorpPalette.sunshine)
                        .symbolEffect(.pulse, isActive: !itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .accessibilityHidden(true)
                }
                DumbField("Food or container name", maxLength: 100, text: $itemName)
                DumbSlider(
                    title: "Quantity",
                    value: $quantity,
                    range: 1...12,
                    step: 1,
                    accent: accent
                )
                Toggle(isOn: $includesUseBy) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Add a use-by reminder")
                            .font(.subheadline.weight(.black))
                            .foregroundStyle(CorpPalette.ink)
                        Text("Use the date on the package or choose your own reminder.")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CorpPalette.mutedInk)
                    }
                }
                .tint(accent)
                .accessibilityIdentifier("useByReminderToggle")

                if includesUseBy {
                    DatePicker(
                        "Use-by reminder",
                        selection: $useByDate,
                        displayedComponents: .date
                    )
                    .font(.subheadline.weight(.black))
                    .tint(accent)
                    .accessibilityIdentifier("useByReminderDate")
                }
            }
        }
    }

    private var inventoryCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 11) {
                HStack {
                    Text("ACTIVE EVIDENCE")
                        .font(.caption2.weight(.black))
                        .tracking(1.2)
                        .foregroundStyle(CorpPalette.mutedInk)
                    Spacer()
                    Text("\(items.count) item types")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .accessibilityIdentifier("fridgeInventoryCount")
                        .accessibilityValue("\(items.count)")
                }

                if items.isEmpty {
                    Label("No fictional cucumber. Add what is really there.", systemImage: "refrigerator")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(CorpPalette.ink)
                        .accessibilityIdentifier("emptyFridgeInventory")
                } else {
                    ForEach(sortedItems) { item in
                        VStack(alignment: .leading, spacing: 7) {
                            HStack {
                                DumbStatusPill(
                                    statusLabel(for: item).uppercased(),
                                    systemImage: statusSymbol(for: item),
                                    accent: accent
                                )
                                Spacer()
                                Text(item.addedDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(CorpPalette.mutedInk)
                            }
                            Text(item.name)
                                .font(.headline.weight(.black))
                                .foregroundStyle(CorpPalette.ink)
                            Text("\(item.quantity) \(item.quantity == 1 ? "unit" : "units")")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(CorpPalette.ink)
                                .accessibilityIdentifier("fridgeItemQuantity")
                                .accessibilityValue("\(item.quantity)")
                            if let useByDate = item.useByDate {
                                Text("Reminder: \(useByDate.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(CorpPalette.mutedInk)
                            } else {
                                Text("No use-by reminder filed")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(CorpPalette.mutedInk)
                            }
                            HStack(spacing: 14) {
                                Button {
                                    useOne(item)
                                } label: {
                                    Label("Use one", systemImage: "minus.circle")
                                        .font(.caption.weight(.black))
                                }
                                .accessibilityIdentifier("useOneFridgeItemButton")

                                Button(role: .destructive) {
                                    discard(item)
                                } label: {
                                    Label("Remove item", systemImage: "trash")
                                        .font(.caption.weight(.black))
                                }
                                .accessibilityIdentifier("discardFridgeItemButton")
                            }
                        }
                        .padding(.vertical, 3)
                    }
                }
            }
        }
    }

    private var sortedItems: [FridgeItem] {
        items.sorted {
            switch ($0.useByDate, $1.useByDate) {
            case let (left?, right?): return left < right
            case (_?, nil): return true
            case (nil, _?): return false
            case (nil, nil): return $0.addedDate > $1.addedDate
            }
        }
    }

    private var totalUnits: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    private var attentionCount: Int {
        items.filter { item in
            guard let useByDate = item.useByDate else { return false }
            return Calendar.current.startOfDay(for: useByDate) <= attentionBoundary
        }.count
    }

    private var attentionBoundary: Date {
        let today = Calendar.current.startOfDay(for: Date())
        return Calendar.current.date(byAdding: .day, value: 3, to: today) ?? today
    }

    private func addItem() {
        let cleanName = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else { return }
        let reminder = includesUseBy ? Calendar.current.startOfDay(for: useByDate) : nil

        if let index = items.firstIndex(where: {
            $0.name.caseInsensitiveCompare(cleanName) == .orderedSame
                && $0.useByDate == reminder
        }) {
            items[index].quantity = min(items[index].quantity + Int(quantity), 99)
        } else {
            items.append(
                FridgeItem(
                    name: cleanName,
                    quantity: Int(quantity),
                    useByDate: reminder
                )
            )
        }
        itemName = ""
        quantity = 1
        persistInventory()
        interrogate()
    }

    private func interrogate() {
        guard !items.isEmpty else {
            statement = Self.emptyStatement
            return
        }
        let overdue = items.filter { statusLabel(for: $0) == "Overdue reminder" }.count
        let dueSoon = items.filter { statusLabel(for: $0) == "Due within 3 days" }.count
        statement = "FRIDGE WITNESS STATEMENT — \(items.count) item \(items.count == 1 ? "type" : "types"), \(totalUnits) total \(totalUnits == 1 ? "unit" : "units"). \(overdue) overdue reminders; \(dueSoon) due within three days. Your reminders—not a freshness or safety verdict."
    }

    private func statusLabel(for item: FridgeItem) -> String {
        guard let useByDate = item.useByDate else { return "No reminder" }
        let date = Calendar.current.startOfDay(for: useByDate)
        let today = Calendar.current.startOfDay(for: Date())
        if date < today { return "Overdue reminder" }
        if date <= attentionBoundary { return "Due within 3 days" }
        return "Later reminder"
    }

    private func statusSymbol(for item: FridgeItem) -> String {
        switch statusLabel(for: item) {
        case "Overdue reminder": return "exclamationmark.triangle.fill"
        case "Due within 3 days": return "clock.badge.exclamationmark.fill"
        case "Later reminder": return "calendar.badge.clock"
        default: return "calendar.badge.minus"
        }
    }

    private func useOne(_ item: FridgeItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        if items[index].quantity > 1 {
            items[index].quantity -= 1
        } else {
            items.remove(at: index)
        }
        persistInventory()
        interrogate()
    }

    private func discard(_ item: FridgeItem) {
        items.removeAll { $0.id == item.id }
        persistInventory()
        interrogate()
    }

    private func eraseAllData() {
        items = []
        itemName = ""
        quantity = 1
        includesUseBy = true
        useByDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        statement = Self.emptyStatement
        persistInventory()
    }

    private func restoreInventory() {
        guard !hasLoaded else { return }
        hasLoaded = true
        guard
            let data = storedItems.data(using: .utf8),
            let saved = try? JSONDecoder().decode([FridgeItem].self, from: data)
        else {
            items = []
            statement = Self.emptyStatement
            return
        }
        items = saved.filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && $0.quantity > 0 }
    }

    private func persistInventory() {
        guard
            let data = try? JSONEncoder().encode(items),
            let value = String(data: data, encoding: .utf8)
        else { return }
        storedItems = value
    }
}

#if canImport(PreviewsMacros)
#Preview { FridgeWitnessView() }
#endif
