import SwiftUI
import DumbKit

private struct PlantRecord: Codable, Identifiable {
    let id: UUID
    var name: String
    var species: String
    var room: String
    var lastWatered: Date
    var intervalDays: Int
    var condition: Int
    var reminderEnabled: Bool
    var wateringDates: [Date]
    let createdAt: Date

    init(
        name: String,
        species: String,
        room: String,
        lastWatered: Date,
        intervalDays: Int,
        condition: Int,
        reminderEnabled: Bool
    ) {
        id = UUID()
        self.name = name
        self.species = species
        self.room = room
        self.lastWatered = lastWatered
        self.intervalDays = intervalDays
        self.condition = condition
        self.reminderEnabled = reminderEnabled
        wateringDates = [lastWatered]
        createdAt = Date()
    }
}

struct PlantCourtView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private static let waitingOrder = "The bench is empty. Add a real plant to open the care docket."

    @AppStorage("plantCourt.draft.name") private var plantName = ""
    @AppStorage("plantCourt.draft.species") private var species = ""
    @AppStorage("plantCourt.draft.room") private var room = ""
    @AppStorage("plantCourt.draft.lastWatered") private var lastWateredTimestamp = 0.0
    @AppStorage("plantCourt.draft.intervalDays") private var intervalDays = 7.0
    @AppStorage("plantCourt.draft.condition") private var condition = 3.0
    @AppStorage("plantCourt.draft.reminder") private var reminderEnabled = false
    @AppStorage("plantCourt.archive") private var storedPlants = "[]"
    @AppStorage("plantCourt.latestOrder") private var latestOrder = Self.waitingOrder

    @State private var plants: [PlantRecord] = []
    @State private var editingID: UUID?
    @State private var hasLoaded = false
    @State private var showAllPlants = false
    @State private var showEraseConfirmation = false
    @State private var notificationMessage = "Off. The court will not send a care reminder."

    private let accent = CorpPalette.parkGreen
    private let gold = CorpPalette.verdictGold

    var body: some View {
        DumbShell(
            eyebrow: "PLANT COURT",
            title: "The care docket",
            subtitle: "A watering log with a ridiculous judicial branch.",
            accent: accent,
            personality: .optimistic
        ) {
            editorCard

            DumbAction(
                title: editingID == nil ? "Add plant to docket" : "Save amended plant record",
                accent: accent,
                systemImage: editingID == nil ? "leaf.fill" : "square.and.pencil",
                action: savePlant
            )
            .disabled(cleanName.isEmpty)
            .accessibilityIdentifier("savePlantRecordButton")

            careOrder

            boundaryCard
            summaryCard

            if hasDraft || editingID != nil {
                Button(action: clearDraft) {
                    Label(editingID == nil ? "Clear filing desk" : "Cancel amendment", systemImage: "arrow.counterclockwise")
                        .font(.subheadline.weight(.black))
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .foregroundStyle(accent)
                .buttonStyle(DumbPressStyle())
                .accessibilityIdentifier("clearPlantDraftButton")
            }

            plantDocket

            Button {
                showEraseConfirmation = true
            } label: {
                Label("Expunge complete plant archive", systemImage: "trash.fill")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(CorpPalette.warningRed)
            .buttonStyle(DumbPressStyle())
            .disabled(plants.isEmpty && !hasDraft && latestOrder == Self.waitingOrder)
            .accessibilityIdentifier("erasePlantArchiveButton")
        }
        .onAppear {
            restorePlants()
            if lastWateredTimestamp == 0 {
                lastWateredTimestamp = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
            }
            refreshNotificationStatus()
        }
        .onChange(of: reminderEnabled) { _, enabled in
            if enabled { refreshNotificationStatus() }
        }
        .confirmationDialog(
            "Expunge every plant record?",
            isPresented: $showEraseConfirmation,
            titleVisibility: .visible
        ) {
            Button("Confirm erase complete plant archive", role: .destructive, action: eraseAll)
            Button("Keep the greenhouse evidence", role: .cancel) {}
        } message: {
            Text("This erases every plant record and reminder. It cannot be undone.")
        }
    }

    private var boundaryCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 8) {
                DumbStatusPill("YOUR CARE RULES", systemImage: "calendar.badge.clock", accent: accent)
                Text("Pick the care interval; we calculate the next check from the last watering. Your plant, your rules.")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CorpPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text("A watering journal—not plant identification or horticultural advice.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
            }
        }
    }

    private var summaryCard: some View {
        DumbCard(accent: gold, isSelected: !plants.isEmpty) {
            HStack(spacing: 8) {
                metric("\(plants.count)", "plants")
                Divider()
                metric("\(duePlantCount)", "due now")
                Divider()
                metric("\(wateringEntryCount)", "waterings")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Plant care summary")
        .accessibilityValue("\(plants.count) plants, \(duePlantCount) due now, \(wateringEntryCount) watering entries")
        .accessibilityIdentifier("plantCareSummary")
    }

    private func metric(_ value: String, _ label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.title3.weight(.black).monospacedDigit())
                .foregroundStyle(accent)
            Text(label.uppercased())
                .font(.caption2.weight(.black))
                .tracking(0.45)
                .foregroundStyle(CorpPalette.mutedInk)
        }
        .frame(maxWidth: .infinity)
    }

    private var editorCard: some View {
        DumbCard(accent: accent, isSelected: editingID != nil || !cleanName.isEmpty) {
            VStack(alignment: .leading, spacing: 14) {
                Text(editingID == nil ? "FILE A PLANT" : "AMEND PLANT RECORD")
                    .font(.caption2.weight(.black).monospaced())
                    .tracking(1.2)
                    .foregroundStyle(CorpPalette.mutedInk)

                DumbField("Plant name", maxLength: 80, text: $plantName)
                DumbField("Species or nickname (optional)", maxLength: 80, text: $species)
                DumbField("Room or location (optional)", maxLength: 80, text: $room)

                DatePicker(
                    "Last watered",
                    selection: lastWateredBinding,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .font(.subheadline.weight(.black))
                .tint(accent)
                .accessibilityIdentifier("lastWateredPicker")

                DumbSlider(title: "Your care interval (days)", value: $intervalDays, range: 1...30, step: 1, accent: accent)
                DumbSlider(title: "Observed condition (1–5)", value: $condition, range: 1...5, step: 1, accent: accent)

                Text("Next check: \(draftNextCheck.formatted(date: .abbreviated, time: .omitted)).")
                    .font(.caption.weight(.black))
                    .foregroundStyle(accent)
                    .accessibilityIdentifier("plantNextCheckPreview")

                Divider()

                Toggle(isOn: $reminderEnabled) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Remind me on the next care date")
                            .font(.subheadline.weight(.black))
                            .foregroundStyle(CorpPalette.ink)
                        Text("We’ll ask before turning this reminder on.")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CorpPalette.mutedInk)
                    }
                }
                .tint(accent)
                .accessibilityIdentifier("plantReminderToggle")

                if reminderEnabled {
                    Text(notificationMessage)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("plantNotificationStatus")
                }
            }
        }
    }

    private var careOrder: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("PLANT COURT · CARE ORDER")
                        .font(.caption.weight(.black).monospaced())
                        .tracking(0.8)
                    Text("USER-SUPPLIED SCHEDULE")
                        .font(.caption2.weight(.bold).monospaced())
                        .foregroundStyle(CorpPalette.mutedInk)
                }
                Spacer()
                Image(systemName: "leaf.circle.fill")
                    .font(.largeTitle.weight(.black))
                    .foregroundStyle(accent)
                    .accessibilityHidden(true)
            }
            Rectangle().fill(accent).frame(height: 3)
            Text(latestOrder)
                .font(.system(.subheadline, design: .serif).weight(.bold))
                .foregroundStyle(CorpPalette.ink)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Text("YOUR CARE PLAN")
                Spacer()
                Text("YOUR PLANT · YOUR CALL")
            }
            .font(.caption2.weight(.black).monospaced())
            .foregroundStyle(CorpPalette.mutedInk)
        }
        .padding(19)
        .background(CorpPalette.surface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(accent, style: StrokeStyle(lineWidth: 2, dash: [5, 4]))
        )
        .shadow(color: accent.opacity(0.16), radius: 0, x: 4, y: 5)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Current plant care order")
        .accessibilityValue(latestOrder)
        .accessibilityIdentifier("plantCareOrder")
    }

    private var plantDocket: some View {
        DumbCard(accent: accent, isSelected: !plants.isEmpty) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    DumbStatusPill("PLANT ARCHIVE", systemImage: "leaf.fill", accent: accent)
                    Spacer()
                    Text("\(plants.count) \(plants.count == 1 ? "plant" : "plants")")
                        .font(.caption.weight(.black))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .accessibilityIdentifier("plantRecordCount")
                        .accessibilityValue("\(plants.count)")
                }

                if plants.isEmpty {
                    Label("No plant has entered evidence.", systemImage: "tray")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .accessibilityIdentifier("emptyPlantDocket")
                } else {
                    ForEach(Array(visiblePlants.enumerated()), id: \.element.id) { index, plant in
                        if index > 0 { Divider() }
                        plantRow(plant)
                    }
                    if plants.count > 5 {
                        Button(showAllPlants ? "Show priority five" : "Browse all \(plants.count) plants") {
                            withAnimation(reduceMotion ? nil : .snappy) { showAllPlants.toggle() }
                        }
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(accent)
                    }
                }
            }
        }
    }

    private func plantRow(_ plant: PlantRecord) -> some View {
        let days = daysUntilDue(plant)
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(plant.name)
                    .font(.headline.weight(.black))
                    .foregroundStyle(CorpPalette.ink)
                Spacer()
                Text(dueLabel(days))
                    .font(.caption2.weight(.black))
                    .foregroundStyle(days <= 0 ? CorpPalette.warningRed : accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background((days <= 0 ? CorpPalette.warningRed : accent).opacity(0.13), in: Capsule())
            }
            if !plant.species.isEmpty || !plant.room.isEmpty {
                Text([plant.species, plant.room].filter { !$0.isEmpty }.joined(separator: " · "))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CorpPalette.ink)
            }
            Text("Last watered \(plant.lastWatered.formatted(date: .abbreviated, time: .omitted)) · every \(plant.intervalDays) days · condition \(plant.condition)/5 by you")
                .font(.caption.weight(.semibold))
                .foregroundStyle(CorpPalette.mutedInk)
            Text("\(plant.wateringDates.count) logged \(plant.wateringDates.count == 1 ? "watering" : "waterings")")
                .font(.caption.weight(.bold))
                .foregroundStyle(CorpPalette.mutedInk)

            HStack(spacing: 10) {
                rowButton("Watered now", image: "drop.fill") { logWatering(plant) }
                rowButton("Edit record", image: "square.and.pencil") { edit(plant) }
            }
            Button(role: .destructive) { delete(plant) } label: {
                Label("Delete plant record", systemImage: "trash")
                    .font(.caption.weight(.black))
            }
        }
        .padding(.vertical, 3)
    }

    private func rowButton(_ title: String, image: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: image)
                .font(.caption.weight(.black))
                .frame(maxWidth: .infinity, minHeight: 36)
        }
        .buttonStyle(.bordered)
        .tint(accent)
    }

    private var cleanName: String { plantName.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var cleanSpecies: String { species.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var cleanRoom: String { room.trimmingCharacters(in: .whitespacesAndNewlines) }

    private var lastWateredBinding: Binding<Date> {
        Binding(
            get: {
                guard lastWateredTimestamp > 0 else { return Calendar.current.startOfDay(for: Date()) }
                return Date(timeIntervalSince1970: lastWateredTimestamp)
            },
            set: { lastWateredTimestamp = Calendar.current.startOfDay(for: $0).timeIntervalSince1970 }
        )
    }

    private var draftNextCheck: Date {
        Calendar.current.date(byAdding: .day, value: Int(intervalDays), to: lastWateredBinding.wrappedValue) ?? lastWateredBinding.wrappedValue
    }

    private var hasDraft: Bool {
        !cleanName.isEmpty || !cleanSpecies.isEmpty || !cleanRoom.isEmpty || Int(intervalDays) != 7 || Int(condition) != 3 || reminderEnabled
    }

    private var duePlantCount: Int { plants.filter { daysUntilDue($0) <= 0 }.count }
    private var wateringEntryCount: Int { plants.reduce(0) { $0 + $1.wateringDates.count } }
    private var sortedPlants: [PlantRecord] {
        plants.sorted {
            let left = daysUntilDue($0)
            let right = daysUntilDue($1)
            return left == right ? $0.createdAt > $1.createdAt : left < right
        }
    }
    private var visiblePlants: [PlantRecord] { showAllPlants ? sortedPlants : Array(sortedPlants.prefix(5)) }

    private func savePlant() {
        guard !cleanName.isEmpty else { return }
        let record: PlantRecord
        if let editingID, let index = plants.firstIndex(where: { $0.id == editingID }) {
            DumbLocalNotifications.cancel(identifier: notificationIdentifier(plants[index]))
            plants[index].name = cleanName
            plants[index].species = cleanSpecies
            plants[index].room = cleanRoom
            plants[index].lastWatered = lastWateredBinding.wrappedValue
            plants[index].intervalDays = Int(intervalDays)
            plants[index].condition = Int(condition)
            plants[index].reminderEnabled = reminderEnabled
            if !plants[index].wateringDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: lastWateredBinding.wrappedValue) }) {
                plants[index].wateringDates.append(lastWateredBinding.wrappedValue)
                plants[index].wateringDates = Array(plants[index].wateringDates.suffix(50))
            }
            record = plants[index]
        } else {
            record = PlantRecord(
                name: cleanName,
                species: cleanSpecies,
                room: cleanRoom,
                lastWatered: lastWateredBinding.wrappedValue,
                intervalDays: Int(intervalDays),
                condition: Int(condition),
                reminderEnabled: reminderEnabled
            )
            plants.insert(record, at: 0)
            let evicted = plants.dropFirst(50)
            DumbLocalNotifications.cancel(identifiers: evicted.map(notificationIdentifier))
            plants = Array(plants.prefix(50))
        }
        latestOrder = order(for: record)
        persistPlants()
        if record.reminderEnabled { scheduleReminder(for: record) }
        clearDraft(keepOrder: true)
    }

    private func order(for plant: PlantRecord) -> String {
        let next = nextCareDate(plant)
        let timing = dueLabel(daysUntilDue(plant)).lowercased()
        return "ORDER — \(plant.name). Last watered \(plant.lastWatered.formatted(date: .abbreviated, time: .omitted)); your \(plant.intervalDays)-day rule sets the next check for \(next.formatted(date: .abbreviated, time: .omitted)) (\(timing)). Observed condition: \(plant.condition)/5, reported by you."
    }

    private func logWatering(_ plant: PlantRecord) {
        guard let index = plants.firstIndex(where: { $0.id == plant.id }) else { return }
        let now = Date()
        plants[index].lastWatered = now
        plants[index].wateringDates.append(now)
        plants[index].wateringDates = Array(plants[index].wateringDates.suffix(50))
        DumbLocalNotifications.cancel(identifier: notificationIdentifier(plant))
        latestOrder = "WATERING FILED — \(plant.name) was marked watered now. The next check follows your \(plant.intervalDays)-day rule."
        persistPlants()
        if plants[index].reminderEnabled { scheduleReminder(for: plants[index]) }
    }

    private func edit(_ plant: PlantRecord) {
        editingID = plant.id
        plantName = plant.name
        species = plant.species
        room = plant.room
        lastWateredTimestamp = plant.lastWatered.timeIntervalSince1970
        intervalDays = Double(plant.intervalDays)
        condition = Double(plant.condition)
        reminderEnabled = plant.reminderEnabled
        latestOrder = "Amendment desk opened for \(plant.name). Save to apply changes."
    }

    private func delete(_ plant: PlantRecord) {
        DumbLocalNotifications.cancel(identifier: notificationIdentifier(plant))
        plants.removeAll { $0.id == plant.id }
        if editingID == plant.id { clearDraft() }
        latestOrder = plants.isEmpty ? Self.waitingOrder : "Plant record dismissed from court."
        persistPlants()
    }

    private func clearDraft() { clearDraft(keepOrder: false) }

    private func clearDraft(keepOrder: Bool) {
        plantName = ""
        species = ""
        room = ""
        lastWateredTimestamp = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
        intervalDays = 7
        condition = 3
        reminderEnabled = false
        editingID = nil
        notificationMessage = "Off. The court will not send a care reminder."
        if !keepOrder { latestOrder = Self.waitingOrder }
    }

    private func eraseAll() {
        DumbLocalNotifications.cancel(identifiers: plants.map(notificationIdentifier))
        plants = []
        showAllPlants = false
        clearDraft()
        persistPlants()
    }

    private func nextCareDate(_ plant: PlantRecord) -> Date {
        Calendar.current.date(byAdding: .day, value: plant.intervalDays, to: plant.lastWatered) ?? plant.lastWatered
    }

    private func daysUntilDue(_ plant: PlantRecord) -> Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: calendar.startOfDay(for: Date()), to: calendar.startOfDay(for: nextCareDate(plant))).day ?? 0
    }

    private func dueLabel(_ days: Int) -> String {
        if days < 0 { return "\(-days)d overdue" }
        if days == 0 { return "Due today" }
        if days == 1 { return "Due tomorrow" }
        return "Due in \(days)d"
    }

    private func notificationIdentifier(_ plant: PlantRecord) -> String { "plant-care-\(plant.id.uuidString)" }

    private func scheduleReminder(for plant: PlantRecord) {
        Task {
            let proposed = max(nextCareDate(plant), Date().addingTimeInterval(60))
            let result = await DumbLocalNotifications.scheduleOneShot(
                identifier: notificationIdentifier(plant),
                title: "Plant Court is back in session",
                body: "A plant care check is due.",
                proposedDate: proposed
            )
            await MainActor.run {
                switch result {
                case .scheduled(let fireDate): notificationMessage = "Care check scheduled for \(fireDate.formatted(date: .abbreviated, time: .shortened))."
                case .denied: notificationMessage = "Reminder not scheduled. Notifications are disabled in Settings."
                case .failed: notificationMessage = "The reminder could not be scheduled. The plant record still saved."
                }
            }
        }
    }

    private func refreshNotificationStatus() {
        guard reminderEnabled else { return }
        Task {
            let status = await DumbLocalNotifications.authorization()
            await MainActor.run {
                switch status {
                case .available: notificationMessage = "Notifications are available. Saving schedules one quiet-hours-aware care check."
                case .notDetermined: notificationMessage = "We’ll ask before turning this reminder on."
                case .denied: notificationMessage = "Notifications are disabled in Settings; saving still works without one."
                }
            }
        }
    }

    private func restorePlants() {
        guard !hasLoaded else { return }
        hasLoaded = true
        guard let data = storedPlants.data(using: .utf8), let decoded = try? JSONDecoder().decode([PlantRecord].self, from: data) else { return }
        plants = decoded
    }

    private func persistPlants() {
        guard let data = try? JSONEncoder().encode(plants), let encoded = String(data: data, encoding: .utf8) else { return }
        storedPlants = encoded
    }
}

#if canImport(PreviewsMacros)
#Preview { PlantCourtView() }
#endif
