import SwiftUI
import DumbKit

private enum LaundryStage: String, Codable, CaseIterable {
    case dirty
    case washing
    case drying
    case folding
    case done

    var label: String { rawValue.uppercased() }
    var icon: String {
        switch self {
        case .dirty: "basket.fill"
        case .washing: "washer.fill"
        case .drying: "wind"
        case .folding: "square.stack.3d.up.fill"
        case .done: "checkmark.seal.fill"
        }
    }
}

private struct LaundryBatch: Codable, Identifiable {
    let id: UUID
    var name: String
    var category: String
    var totalLoads: Int
    var completedLoads: Int
    var stage: LaundryStage
    var washMinutes: Int
    var dryMinutes: Int
    var remindersEnabled: Bool
    let createdAt: Date
    var updatedAt: Date

    init(name: String, category: String, totalLoads: Int, washMinutes: Int, dryMinutes: Int, remindersEnabled: Bool) {
        id = UUID()
        self.name = name
        self.category = category
        self.totalLoads = totalLoads
        completedLoads = 0
        stage = .dirty
        self.washMinutes = washMinutes
        self.dryMinutes = dryMinutes
        self.remindersEnabled = remindersEnabled
        createdAt = Date()
        updatedAt = Date()
    }
}

struct LaundryMountainView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private static let waitingTicket = "No laundry is queued. The mountain currently lacks legal standing."

    @AppStorage("laundryMountain.draft.name") private var batchName = ""
    @AppStorage("laundryMountain.draft.category") private var category = "Everyday clothes"
    @AppStorage("laundryMountain.draft.loads") private var totalLoads = 2.0
    @AppStorage("laundryMountain.draft.washMinutes") private var washMinutes = 45.0
    @AppStorage("laundryMountain.draft.dryMinutes") private var dryMinutes = 50.0
    @AppStorage("laundryMountain.draft.reminders") private var remindersEnabled = false
    @AppStorage("laundryMountain.archive") private var storedBatches = "[]"
    @AppStorage("laundryMountain.latestTicket") private var latestTicket = Self.waitingTicket

    @State private var batches: [LaundryBatch] = []
    @State private var editingID: UUID?
    @State private var hasLoaded = false
    @State private var showAll = false
    @State private var showEraseConfirmation = false
    @State private var notificationMessage = "Off. Stage timers will stay inside the app."

    private let categories = ["Everyday clothes", "Darks", "Lights", "Towels", "Bedding", "Delicates", "Sportswear", "Other"]
    private let accent = CorpPalette.detergentBlue
    private let warning = CorpPalette.warningRed

    var body: some View {
        AppCanvas(accent: accent) {
            AppHeader(
                eyebrow: "LAUNDRY MOUNTAIN",
                title: "The expedition board",
                subtitle: "Move real loads through the mountain instead of measuring imaginary danger.",
                accent: accent
            )

            batchEditor

            expeditionTicket

            boundaryCard
            summaryCard

            if hasDraft || editingID != nil {
            Button(action: clearDraft) {
            Label(editingID == nil ? "Clear staging area" : "Cancel batch edit", systemImage: "arrow.counterclockwise")
            .font(.subheadline.weight(.black))
            .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .accessibilityIdentifier("clearLaundryDraftButton")
            }

            queueCard

            Button { showEraseConfirmation = true } label: {
            Label("Flatten complete laundry archive", systemImage: "trash.fill")
            .font(.subheadline.weight(.black))
            .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(warning)
            .buttonStyle(DumbPressStyle())
            .disabled(batches.isEmpty && !hasDraft && latestTicket == Self.waitingTicket)
            .accessibilityIdentifier("eraseLaundryArchiveButton")

        } bottomBar: {
            DumbAction(
            title: editingID == nil ? "Add batch to the mountain" : "Save batch changes",
            accent: accent,
            systemImage: editingID == nil ? "mountain.2.fill" : "square.and.pencil",
            action: saveBatch
            )
            .disabled(cleanName.isEmpty)
            .accessibilityIdentifier("saveLaundryBatchButton")

            if latestTicket != Self.waitingTicket {
                DumbShareVerdict(
                    text: latestTicket,
                    subject: "Laundry expedition ticket",
                    accent: accent,
                    accessibilityIdentifier: "shareLaundryTicketButton"
                )
            }

        }
        .onAppear {
            restoreBatches()
            refreshNotificationStatus()
        }
        .onChange(of: remindersEnabled) { _, enabled in if enabled { refreshNotificationStatus() } }
        .confirmationDialog("Flatten every laundry record?", isPresented: $showEraseConfirmation, titleVisibility: .visible) {
            Button("Confirm erase complete laundry archive", role: .destructive, action: eraseAll)
            Button("Keep climbing", role: .cancel) {}
        } message: {
            Text("This erases every batch and stage reminder. It cannot be undone.")
        }
    }

    private var boundaryCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 8) {
                DumbStatusPill("LAUNDRY EXPEDITION", systemImage: "figure.hiking", accent: accent)
                Text("You move each batch through Dirty → Washing → Drying → Folding → Done. Optional timers only remind you when to check.")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CorpPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text("You run the machines. The expedition board keeps the plan moving.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
            }
        }
    }

    private var summaryCard: some View {
        DumbCard(accent: accent, isSelected: !batches.isEmpty) {
            HStack(spacing: 8) {
                metric("\(activeBatches.count)", "active")
                Divider()
                metric("\(remainingLoads)", "loads left")
                Divider()
                metric("\(finishedLoads)", "finished")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Laundry queue summary")
        .accessibilityValue("\(activeBatches.count) active batches, \(remainingLoads) loads left, \(finishedLoads) finished loads")
        .accessibilityIdentifier("laundryQueueSummary")
    }

    private func metric(_ value: String, _ label: String) -> some View {
        VStack(spacing: 3) {
            Text(value).font(.title3.weight(.black).monospacedDigit()).foregroundStyle(accent)
            Text(label.uppercased()).font(.caption2.weight(.black)).tracking(0.4).foregroundStyle(CorpPalette.mutedInk)
        }
        .frame(maxWidth: .infinity)
    }

    private var batchEditor: some View {
        DumbCard(accent: accent, isSelected: editingID != nil || !cleanName.isEmpty) {
            VStack(alignment: .leading, spacing: 14) {
                Text(editingID == nil ? "PLAN A BATCH" : "EDIT BATCH PLAN")
                    .font(.caption2.weight(.black).monospaced()).tracking(1.2).foregroundStyle(CorpPalette.mutedInk)
                DumbField("Batch name", maxLength: 90, text: $batchName)
                Picker("Laundry category", selection: $category) {
                    ForEach(categories, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.menu).font(.subheadline.weight(.black)).tint(accent)
                DumbSlider(title: "Estimated loads", value: $totalLoads, range: 1...10, step: 1, accent: accent)
                DumbSlider(title: "Expected wash minutes", value: $washMinutes, range: 15...120, step: 5, accent: accent)
                DumbSlider(title: "Expected dry minutes", value: $dryMinutes, range: 15...120, step: 5, accent: CorpPalette.sunshine)
                Toggle(isOn: $remindersEnabled) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Remind me when a timed stage is expected to finish")
                            .font(.subheadline.weight(.black)).foregroundStyle(CorpPalette.ink)
                        Text("We’ll ask before turning stage reminders on.")
                            .font(.caption.weight(.semibold)).foregroundStyle(CorpPalette.mutedInk)
                    }
                }
                .tint(accent)
                .accessibilityIdentifier("laundryReminderToggle")
                if remindersEnabled {
                    Text(notificationMessage)
                        .font(.caption.weight(.bold)).foregroundStyle(CorpPalette.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("laundryNotificationStatus")
                }
            }
        }
    }

    private var expeditionTicket: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("MOUNTAIN EXPEDITION TICKET").font(.caption.weight(.black).monospaced()).tracking(0.8)
                    Text("EXPEDITION TICKET").font(.caption2.weight(.bold).monospaced()).foregroundStyle(CorpPalette.mutedInk)
                }
                Spacer()
                Image(systemName: "mountain.2.circle.fill").font(.largeTitle.weight(.black)).foregroundStyle(accent).accessibilityHidden(true)
            }
            Rectangle().fill(accent).frame(height: 3)
            Text(latestTicket)
                .font(.system(.subheadline, design: .monospaced).weight(.bold))
                .foregroundStyle(CorpPalette.ink).fixedSize(horizontal: false, vertical: true)
            stageTrail
            HStack { Text("YOUR TIMERS"); Spacer(); Text("YOUR LOADS") }
                .font(.caption2.weight(.black).monospaced()).foregroundStyle(CorpPalette.mutedInk)
        }
        .padding(19)
        .background(CorpPalette.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(accent, style: StrokeStyle(lineWidth: 2, dash: [10, 4, 2, 4])))
        .shadow(color: accent.opacity(0.17), radius: 0, x: 4, y: 5)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Laundry expedition ticket")
        .accessibilityValue(latestTicket)
        .accessibilityIdentifier("laundryExpeditionTicket")
    }

    private var stageTrail: some View {
        HStack(spacing: 4) {
            ForEach(LaundryStage.allCases, id: \.self) { stage in
                VStack(spacing: 3) {
                    Image(systemName: stage.icon).font(.caption.weight(.black))
                    Text(stage == .folding ? "FOLD" : stage.label).font(.caption2.weight(.black))
                }
                .frame(maxWidth: .infinity).foregroundStyle(accent)
            }
        }
        .padding(.vertical, 8)
        .background(accent.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        .accessibilityHidden(true)
    }

    private var queueCard: some View {
        DumbCard(accent: accent, isSelected: !batches.isEmpty) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    DumbStatusPill("ACTIVE EXPEDITION", systemImage: "list.bullet.clipboard.fill", accent: accent)
                    Spacer()
                    Text("\(batches.count) \(batches.count == 1 ? "batch" : "batches")")
                        .font(.caption.weight(.black)).foregroundStyle(CorpPalette.mutedInk)
                        .accessibilityIdentifier("laundryBatchCount").accessibilityValue("\(batches.count)")
                }
                if batches.isEmpty {
                    DumbEmptyInvite(
                        title: "Mountain at rest",
                        message: "Add a laundry batch to open the expedition ticket.",
                        systemImage: "mountain.2.fill",
                        accent: accent
                    )
                    .accessibilityIdentifier("emptyLaundryQueue")
                } else {
                    ForEach(Array(visibleBatches.enumerated()), id: \.element.id) { index, batch in
                        if index > 0 { Divider() }
                        batchRow(batch)
                    }
                    if batches.count > 5 {
                        Button(showAll ? "Show priority five" : "Browse all \(batches.count) batches") { withAnimation(reduceMotion ? nil : .snappy) { showAll.toggle() } }
                            .font(.subheadline.weight(.black)).foregroundStyle(accent)
                    }
                }
            }
        }
    }

    private func batchRow(_ batch: LaundryBatch) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(batch.name).font(.headline.weight(.black)).foregroundStyle(CorpPalette.ink)
                Spacer()
                Label(batch.stage.label, systemImage: batch.stage.icon)
                    .font(.caption2.weight(.black)).foregroundStyle(batch.stage == .done ? CorpPalette.parkGreen : accent)
                    .padding(.horizontal, 8).padding(.vertical, 5)
                    .background((batch.stage == .done ? CorpPalette.evidenceMint : accent).opacity(0.16), in: Capsule())
            }
            Text("\(batch.category) · \(batch.completedLoads)/\(batch.totalLoads) loads folded")
                .font(.subheadline.weight(.bold)).foregroundStyle(CorpPalette.ink)
            Text("Expected: \(batch.washMinutes)m wash · \(batch.dryMinutes)m dry · moved by you")
                .font(.caption.weight(.semibold)).foregroundStyle(CorpPalette.mutedInk)

            if batch.stage != .done {
                rowButton(nextActionTitle(batch), image: nextActionIcon(batch)) { advance(batch) }
                if batch.stage != .dirty {
                    rowButton("Move back one stage", image: "arrow.uturn.backward") { moveBack(batch) }
                }
                rowButton("Edit batch", image: "square.and.pencil") { edit(batch) }
            } else {
                rowButton("Reopen one load", image: "arrow.uturn.backward") { reopen(batch) }
            }
            Button(role: .destructive) { delete(batch) } label: {
                Label("Delete laundry batch", systemImage: "trash").font(.caption.weight(.black))
            }
        }
        .padding(.vertical, 3)
    }

    private func rowButton(_ title: String, image: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: image).font(.caption.weight(.black)).frame(maxWidth: .infinity, minHeight: DumbMetrics.minimumTapTarget)
        }
        .buttonStyle(.bordered).tint(accent)
    }

    private var cleanName: String { batchName.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var hasDraft: Bool { !cleanName.isEmpty || category != "Everyday clothes" || Int(totalLoads) != 2 || Int(washMinutes) != 45 || Int(dryMinutes) != 50 || remindersEnabled }
    private var activeBatches: [LaundryBatch] { batches.filter { $0.stage != .done } }
    private var remainingLoads: Int { activeBatches.reduce(0) { $0 + max(0, $1.totalLoads - $1.completedLoads) } }
    private var finishedLoads: Int { batches.reduce(0) { $0 + $1.completedLoads } }
    private var sortedBatches: [LaundryBatch] { batches.sorted { ($0.stage == .done ? 1 : 0, $0.updatedAt) < ($1.stage == .done ? 1 : 0, $1.updatedAt) } }
    private var visibleBatches: [LaundryBatch] { showAll ? sortedBatches : Array(sortedBatches.prefix(5)) }

    private func saveBatch() {
        guard !cleanName.isEmpty else { return }
        let saved: LaundryBatch
        if let editingID, let index = batches.firstIndex(where: { $0.id == editingID }) {
            DumbLocalNotifications.cancel(identifier: notificationIdentifier(batches[index]))
            batches[index].name = cleanName
            batches[index].category = category
            batches[index].totalLoads = max(Int(totalLoads), batches[index].completedLoads + (batches[index].stage == .done ? 0 : 1))
            batches[index].washMinutes = Int(washMinutes)
            batches[index].dryMinutes = Int(dryMinutes)
            batches[index].remindersEnabled = remindersEnabled
            batches[index].updatedAt = Date()
            saved = batches[index]
        } else {
            saved = LaundryBatch(name: cleanName, category: category, totalLoads: Int(totalLoads), washMinutes: Int(washMinutes), dryMinutes: Int(dryMinutes), remindersEnabled: remindersEnabled)
            batches.insert(saved, at: 0)
            let evicted = batches.dropFirst(50)
            DumbLocalNotifications.cancel(identifiers: evicted.map(notificationIdentifier))
            batches = Array(batches.prefix(50))
        }
        latestTicket = "QUEUED — \(saved.name): \(saved.totalLoads - saved.completedLoads) loads remain, currently \(saved.stage.rawValue). You control every stage change."
        persistBatches()
        clearDraft(keepTicket: true)
    }

    private func nextActionTitle(_ batch: LaundryBatch) -> String {
        switch batch.stage {
        case .dirty: "Start washing"
        case .washing: "Move to dryer"
        case .drying: "Ready to fold"
        case .folding: "Folded one load"
        case .done: "Done"
        }
    }
    private func nextActionIcon(_ batch: LaundryBatch) -> String {
        switch batch.stage {
        case .dirty: "washer.fill"
        case .washing: "wind"
        case .drying: "square.stack.3d.up.fill"
        case .folding: "checkmark.circle.fill"
        case .done: "checkmark.seal.fill"
        }
    }

    private func advance(_ batch: LaundryBatch) {
        guard let index = batches.firstIndex(where: { $0.id == batch.id }) else { return }
        DumbLocalNotifications.cancel(identifier: notificationIdentifier(batch))
        switch batches[index].stage {
        case .dirty:
            batches[index].stage = .washing
            latestTicket = "WASHING — \(batch.name). Expected duration: \(batch.washMinutes) minutes, entered by you."
        case .washing:
            batches[index].stage = .drying
            latestTicket = "DRYING — \(batch.name). Expected duration: \(batch.dryMinutes) minutes, entered by you."
        case .drying:
            batches[index].stage = .folding
            latestTicket = "FOLDING CAMP — \(batch.name) is waiting for a human finish."
        case .folding:
            batches[index].completedLoads += 1
            batches[index].stage = batches[index].completedLoads >= batches[index].totalLoads ? .done : .dirty
            latestTicket = batches[index].stage == .done
                ? "SUMMIT — \(batch.name) completed \(batches[index].totalLoads)/\(batches[index].totalLoads) loads."
                : "LOAD FOLDED — \(batch.name) has \(batches[index].totalLoads - batches[index].completedLoads) loads remaining."
        case .done: break
        }
        batches[index].updatedAt = Date()
        persistBatches()
        if batches[index].remindersEnabled && [.washing, .drying].contains(batches[index].stage) { scheduleStageReminder(for: batches[index]) }
    }

    private func moveBack(_ batch: LaundryBatch) {
        guard let index = batches.firstIndex(where: { $0.id == batch.id }) else { return }
        DumbLocalNotifications.cancel(identifier: notificationIdentifier(batch))
        switch batches[index].stage {
        case .washing: batches[index].stage = .dirty
        case .drying: batches[index].stage = .washing
        case .folding: batches[index].stage = .drying
        default: return
        }
        batches[index].updatedAt = Date()
        latestTicket = "STAGE CORRECTED — \(batch.name) moved back to \(batches[index].stage.rawValue) by you."
        persistBatches()
    }

    private func reopen(_ batch: LaundryBatch) {
        guard let index = batches.firstIndex(where: { $0.id == batch.id }), batches[index].completedLoads > 0 else { return }
        batches[index].completedLoads -= 1
        batches[index].stage = .dirty
        batches[index].updatedAt = Date()
        latestTicket = "REOPENED — One load from \(batch.name) returned to the dirty trail."
        persistBatches()
    }

    private func edit(_ batch: LaundryBatch) {
        editingID = batch.id
        batchName = batch.name
        category = batch.category
        totalLoads = Double(batch.totalLoads)
        washMinutes = Double(batch.washMinutes)
        dryMinutes = Double(batch.dryMinutes)
        remindersEnabled = batch.remindersEnabled
        latestTicket = "EDIT CAMP OPEN — Change \(batch.name), then save without duplicating it."
    }

    private func delete(_ batch: LaundryBatch) {
        DumbLocalNotifications.cancel(identifier: notificationIdentifier(batch))
        batches.removeAll { $0.id == batch.id }
        if editingID == batch.id { clearDraft() }
        latestTicket = batches.isEmpty ? Self.waitingTicket : "Batch removed from the expedition board."
        persistBatches()
    }

    private func clearDraft() { clearDraft(keepTicket: false) }
    private func clearDraft(keepTicket: Bool) {
        batchName = ""; category = "Everyday clothes"; totalLoads = 2; washMinutes = 45; dryMinutes = 50
        remindersEnabled = false; editingID = nil; notificationMessage = "Off. Stage timers will stay inside the app."
        if !keepTicket { latestTicket = Self.waitingTicket }
    }

    private func eraseAll() {
        DumbLocalNotifications.cancel(identifiers: batches.map(notificationIdentifier))
        batches = []; showAll = false; clearDraft(); persistBatches()
    }

    private func notificationIdentifier(_ batch: LaundryBatch) -> String { "laundry-stage-\(batch.id.uuidString)" }
    private func scheduleStageReminder(for batch: LaundryBatch) {
        let minutes = batch.stage == .washing ? batch.washMinutes : batch.dryMinutes
        Task {
            let result = await DumbLocalNotifications.scheduleOneShot(
                identifier: notificationIdentifier(batch),
                title: "Laundry Mountain checkpoint",
                body: "A laundry stage may be ready for inspection.",
                proposedDate: Date().addingTimeInterval(Double(minutes) * 60)
            )
            await MainActor.run {
                switch result {
                case .scheduled(let date): notificationMessage = "Stage check scheduled for \(date.formatted(date: .omitted, time: .shortened))."
                case .denied: notificationMessage = "Timer not scheduled. Notifications are disabled in Settings."
                case .failed: notificationMessage = "The reminder didn’t stick. The expedition still continues."
                }
            }
        }
    }

    private func refreshNotificationStatus() {
        guard remindersEnabled else { return }
        Task {
            let status = await DumbLocalNotifications.authorization()
            await MainActor.run {
                switch status {
                case .available: notificationMessage = "Notifications are available. Starting wash or dry schedules one stage check."
                case .notDetermined: notificationMessage = "We’ll ask before turning stage reminders on."
                case .denied: notificationMessage = "Notifications are disabled in Settings; stage tracking still works."
                }
            }
        }
    }

    private func restoreBatches() {
        guard !hasLoaded else { return }; hasLoaded = true
        guard let data = storedBatches.data(using: .utf8), let decoded = try? JSONDecoder().decode([LaundryBatch].self, from: data) else { return }
        batches = decoded
    }
    private func persistBatches() {
        guard let data = try? JSONEncoder().encode(batches), let encoded = String(data: data, encoding: .utf8) else { return }
        storedBatches = encoded
    }
}

#if canImport(PreviewsMacros)
#Preview { LaundryMountainView() }
#endif
