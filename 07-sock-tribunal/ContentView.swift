import SwiftUI
import DumbKit

private enum SockCaseStatus: String, Codable {
    case open
    case reunited
    case closedUnsolved

    var label: String {
        switch self {
        case .open: "OPEN"
        case .reunited: "REUNITED"
        case .closedUnsolved: "CLOSED UNSOLVED"
        }
    }
}

private struct SockCase: Codable, Identifiable {
    let id: UUID
    var sockName: String
    var color: String
    var pattern: String
    var lastSeen: String
    var missingSince: Date
    var status: SockCaseStatus
    var reminderDays: Int?
    let filedAt: Date
    var resolvedAt: Date?

    init(
        sockName: String,
        color: String,
        pattern: String,
        lastSeen: String,
        missingSince: Date,
        reminderDays: Int?
    ) {
        id = UUID()
        self.sockName = sockName
        self.color = color
        self.pattern = pattern
        self.lastSeen = lastSeen
        self.missingSince = missingSince
        status = .open
        self.reminderDays = reminderDays
        filedAt = Date()
        resolvedAt = nil
    }
}

struct SockTribunalView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private static let waitingOrder = "No ruling yet. File a real missing-sock case to convene the court."

    @AppStorage("sockTribunal.draft.name") private var sockName = ""
    @AppStorage("sockTribunal.draft.color") private var color = "Black"
    @AppStorage("sockTribunal.draft.pattern") private var pattern = "Plain"
    @AppStorage("sockTribunal.draft.lastSeen") private var lastSeen = ""
    @AppStorage("sockTribunal.draft.missingSince") private var missingSinceTimestamp = 0.0
    @AppStorage("sockTribunal.draft.reminderEnabled") private var reminderEnabled = false
    @AppStorage("sockTribunal.draft.reminderDays") private var reminderDays = 3.0
    @AppStorage("sockTribunal.latestOrder") private var latestOrder = Self.waitingOrder
    @AppStorage("sockTribunal.caseArchive") private var storedCases = "[]"

    @State private var cases: [SockCase] = []
    @State private var hasLoaded = false
    @State private var showAllCases = false
    @State private var showEraseConfirmation = false
    @State private var notificationMessage = "Off. The court will not contact you."

    private let colors = ["Black", "White", "Grey", "Blue", "Red", "Green", "Yellow", "Pink", "Purple", "Other"]
    private let patterns = ["Plain", "Striped", "Spotted", "Graphic", "Sport", "Formal", "Unclassifiable"]
    private let accent = CorpPalette.verdictGold
    private let navy = CorpPalette.courtroomNavy

    var body: some View {
        AppCanvas(accent: accent) {
            AppHeader(
                eyebrow: "THE SOCK TRIBUNAL",
                title: "The laundry docket",
                subtitle: "File real missing socks, track the search, and record reunions. Justice may be laundered.",
                accent: accent
            )

            filingDesk

            courtOrder

            rulesCard
            summaryCard

            if hasDraft {
            Button(action: clearDraft) {
            Label("Clear filing desk", systemImage: "arrow.counterclockwise")
            .font(.subheadline.weight(.black))
            .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(navy)
            .buttonStyle(DumbPressStyle())
            .accessibilityIdentifier("clearSockDraftButton")
            }

            docket

            Button {
            showEraseConfirmation = true
            } label: {
            Label("Expunge complete sock archive", systemImage: "trash.fill")
            .font(.subheadline.weight(.black))
            .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(CorpPalette.warningRed)
            .buttonStyle(DumbPressStyle())
            .disabled(cases.isEmpty && !hasDraft && latestOrder == Self.waitingOrder)
            .accessibilityIdentifier("eraseSockArchiveButton")

        } bottomBar: {
            DumbAction(
            title: "File case & issue order",
            accent: accent,
            systemImage: "building.columns.fill",
            action: fileCase
            )
            .disabled(cleanName.isEmpty)
            .accessibilityIdentifier("fileSockCaseButton")

        }
        .onAppear {
            restoreCases()
            if missingSinceTimestamp == 0 {
                missingSinceTimestamp = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
            }
            refreshNotificationStatus()
        }
        .onChange(of: reminderEnabled) { _, enabled in
            if enabled { refreshNotificationStatus() }
        }
        .confirmationDialog(
            "Expunge every sock case?",
            isPresented: $showEraseConfirmation,
            titleVisibility: .visible
        ) {
            Button("Confirm erase complete sock archive", role: .destructive, action: eraseAll)
            Button("Keep the docket", role: .cancel) {}
        } message: {
            Text("This erases every sock case and reminder. It cannot be undone.")
        }
    }

    private var rulesCard: some View {
        DumbCard(accent: navy) {
            VStack(alignment: .leading, spacing: 8) {
                DumbStatusPill("PUBLISHED COURT STAGES", systemImage: "books.vertical.fill", accent: navy)
                Text("Cases age from intake → active search → cold case → presumed independent. You close every case yourself.")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CorpPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var summaryCard: some View {
        DumbCard(accent: accent, isSelected: !cases.isEmpty) {
            HStack(spacing: 8) {
                summaryMetric("\(openCases.count)", "open")
                Divider()
                summaryMetric("\(reunitedCount)", "reunited")
                Divider()
                summaryMetric(oldestOpenDays.map(String.init) ?? "—", "oldest days")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Sock docket summary")
        .accessibilityValue(summaryAccessibilityValue)
        .accessibilityIdentifier("sockDocketSummary")
    }

    private func summaryMetric(_ value: String, _ label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.title3.weight(.black).monospacedDigit())
                .foregroundStyle(navy)
            Text(label.uppercased())
                .font(.caption2.weight(.black))
                .tracking(0.5)
                .foregroundStyle(CorpPalette.mutedInk)
        }
        .frame(maxWidth: .infinity)
    }

    private var filingDesk: some View {
        DumbCard(accent: navy, isSelected: !cleanName.isEmpty) {
            VStack(alignment: .leading, spacing: 14) {
                Text("FILE NEW CASE")
                    .font(.caption2.weight(.black).monospaced())
                    .tracking(1.3)
                    .foregroundStyle(CorpPalette.mutedInk)

                DumbField("Describe the unmatched sock", maxLength: 100, text: $sockName)
                    .accessibilityIdentifier("sockDescriptionField")

                HStack(spacing: 12) {
                    evidencePicker("Color", selection: $color, options: colors)
                    evidencePicker("Pattern", selection: $pattern, options: patterns)
                }

                DumbField("Last seen location (optional)", maxLength: 100, text: $lastSeen)
                    .accessibilityIdentifier("sockLastSeenField")

                DatePicker(
                    "Missing since",
                    selection: missingSinceBinding,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .font(.subheadline.weight(.black))
                .foregroundStyle(CorpPalette.ink)
                .tint(navy)
                .accessibilityIdentifier("sockMissingSincePicker")

                Text("The docket will record \(draftMissingDays) missing \(draftMissingDays == 1 ? "day" : "days") as of today.")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CorpPalette.mutedInk)
                    .accessibilityIdentifier("sockMissingDaysPreview")

                Divider()

                Toggle(isOn: $reminderEnabled) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Remind me to recheck this case")
                            .font(.subheadline.weight(.black))
                            .foregroundStyle(CorpPalette.ink)
                        Text("We’ll ask before turning this reminder on.")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CorpPalette.mutedInk)
                    }
                }
                .tint(accent)
                .accessibilityIdentifier("sockReminderToggle")

                if reminderEnabled {
                    DumbSlider(
                        title: "Recheck in days",
                        value: $reminderDays,
                        range: 1...14,
                        step: 1,
                        accent: accent
                    )
                    Text(notificationMessage)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("sockNotificationStatus")
                }
            }
        }
    }

    private func evidencePicker(_ title: String, selection: Binding<String>, options: [String]) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title.uppercased())
                .font(.caption2.weight(.black))
                .tracking(0.7)
                .foregroundStyle(CorpPalette.mutedInk)
            Picker(title, selection: selection) {
                ForEach(options, id: \.self) { Text($0).tag($0) }
            }
            .pickerStyle(.menu)
            .font(.subheadline.weight(.black))
            .tint(navy)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var courtOrder: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SUPERIOR COURT OF LAUNDRY")
                        .font(.caption.weight(.black).monospaced())
                        .tracking(0.8)
                    Text("CURRENT COURT ORDER")
                        .font(.caption2.weight(.bold).monospaced())
                        .foregroundStyle(CorpPalette.mutedInk)
                }
                Spacer()
                ZStack {
                    Circle().fill(accent)
                    Image(systemName: "gavel.fill")
                        .font(.headline.weight(.black))
                        .foregroundStyle(navy)
                }
                .frame(width: 42, height: 42)
                .rotationEffect(.degrees(latestOrder == Self.waitingOrder ? 0 : -9))
                .accessibilityHidden(true)
            }

            Rectangle().fill(navy).frame(height: 3)

            Text(latestOrder)
                .font(.system(.subheadline, design: .serif).weight(.bold))
                .foregroundStyle(CorpPalette.ink)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Text("CASE FILE")
                Spacer()
                Text("NO AUTOMATIC VERDICTS")
            }
            .font(.caption2.weight(.black).monospaced())
            .foregroundStyle(CorpPalette.mutedInk)
        }
        .padding(19)
        .background(CorpPalette.surface, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(navy, style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
        )
        .shadow(color: navy.opacity(0.16), radius: 0, x: 4, y: 5)
        .rotationEffect(.degrees(latestOrder == Self.waitingOrder ? 0 : 0.35))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Current sock court order")
        .accessibilityValue(latestOrder)
        .accessibilityIdentifier("sockCourtOrder")
    }

    private var docket: some View {
        DumbCard(accent: navy, isSelected: !cases.isEmpty) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    DumbStatusPill("SOCK DOCKET", systemImage: "doc.text.magnifyingglass", accent: navy)
                    Spacer()
                    Text("\(cases.count) \(cases.count == 1 ? "case" : "cases")")
                        .font(.caption.weight(.black))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .accessibilityIdentifier("sockCaseCount")
                        .accessibilityValue("\(cases.count)")
                }

                if cases.isEmpty {
                    Label("No sock has entered evidence.", systemImage: "tray")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .accessibilityIdentifier("emptySockDocket")
                } else {
                    ForEach(Array(visibleCases.enumerated()), id: \.element.id) { index, sockCase in
                        if index > 0 { Divider() }
                        caseRow(sockCase)
                    }

                    if cases.count > 5 {
                        Button(showAllCases ? "Show priority five" : "Browse all \(cases.count) cases") {
                            withAnimation(reduceMotion ? nil : .snappy) { showAllCases.toggle() }
                        }
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(navy)
                        .accessibilityIdentifier("toggleSockDocketButton")
                    }
                }
            }
        }
    }

    private func caseRow(_ sockCase: SockCase) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("CASE \(caseNumber(sockCase))")
                    .font(.caption2.weight(.black).monospaced())
                    .foregroundStyle(CorpPalette.mutedInk)
                Spacer()
                Text(sockCase.status.label)
                    .font(.caption2.weight(.black))
                    .foregroundStyle(sockCase.status == .open ? navy : CorpPalette.parkGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background((sockCase.status == .open ? accent : CorpPalette.evidenceMint).opacity(0.22), in: Capsule())
            }

            Text(sockCase.sockName)
                .font(.headline.weight(.black))
                .foregroundStyle(CorpPalette.ink)
            Text("\(sockCase.color) · \(sockCase.pattern) · missing \(missingDays(for: sockCase)) \(missingDays(for: sockCase) == 1 ? "day" : "days")")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(CorpPalette.ink)
            if !sockCase.lastSeen.isEmpty {
                Label("Last seen: \(sockCase.lastSeen)", systemImage: "mappin.and.ellipse")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
            }
            if let days = sockCase.reminderDays, sockCase.status == .open {
                Label("Recheck requested after \(days) \(days == 1 ? "day" : "days")", systemImage: "bell.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
            }

            if sockCase.status == .open {
                HStack(spacing: 10) {
                    docketButton("Reunited", image: "checkmark.circle.fill", identifier: "reuniteSockCaseButton") {
                        resolve(sockCase, as: .reunited)
                    }
                    docketButton("Close unsolved", image: "folder.badge.minus", identifier: "closeSockCaseButton") {
                        resolve(sockCase, as: .closedUnsolved)
                    }
                }
            } else {
                docketButton("Reopen search", image: "arrow.uturn.backward", identifier: "reopenSockCaseButton") {
                    reopen(sockCase)
                }
            }

            Button(role: .destructive) {
                delete(sockCase)
            } label: {
                Label("Delete case", systemImage: "trash")
                    .font(.caption.weight(.black))
            }
            .accessibilityIdentifier("deleteSockCaseButton")
        }
        .padding(.vertical, 3)
        .accessibilityIdentifier("sockCaseRow")
    }

    private func docketButton(_ title: String, image: String, identifier: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: image)
                .font(.caption.weight(.black))
                .frame(maxWidth: .infinity, minHeight: DumbMetrics.minimumTapTarget)
        }
        .foregroundStyle(navy)
        .buttonStyle(.bordered)
        .tint(accent)
        .accessibilityIdentifier(identifier)
    }

    private var cleanName: String {
        sockName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var cleanLastSeen: String {
        lastSeen.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var missingSinceBinding: Binding<Date> {
        Binding(
            get: {
                guard missingSinceTimestamp > 0 else { return Calendar.current.startOfDay(for: Date()) }
                return Date(timeIntervalSince1970: missingSinceTimestamp)
            },
            set: { missingSinceTimestamp = Calendar.current.startOfDay(for: $0).timeIntervalSince1970 }
        )
    }

    private var draftMissingDays: Int {
        daysBetween(missingSinceBinding.wrappedValue, Date())
    }

    private var hasDraft: Bool {
        !cleanName.isEmpty
            || color != "Black"
            || pattern != "Plain"
            || !cleanLastSeen.isEmpty
            || draftMissingDays > 0
            || reminderEnabled
            || reminderDays != 3
    }

    private var openCases: [SockCase] {
        cases.filter { $0.status == .open }
    }

    private var reunitedCount: Int {
        cases.filter { $0.status == .reunited }.count
    }

    private var oldestOpenDays: Int? {
        openCases.map(missingDays).max()
    }

    private var summaryAccessibilityValue: String {
        let oldest = oldestOpenDays.map { "\($0) days" } ?? "none"
        return "\(openCases.count) open, \(reunitedCount) reunited, oldest open \(oldest)"
    }

    private var sortedCases: [SockCase] {
        cases.sorted {
            if ($0.status == .open) != ($1.status == .open) { return $0.status == .open }
            return $0.filedAt > $1.filedAt
        }
    }

    private var visibleCases: [SockCase] {
        showAllCases ? sortedCases : Array(sortedCases.prefix(5))
    }

    private func fileCase() {
        guard !cleanName.isEmpty else { return }
        let newCase = SockCase(
            sockName: cleanName,
            color: color,
            pattern: pattern,
            lastSeen: cleanLastSeen,
            missingSince: missingSinceBinding.wrappedValue,
            reminderDays: reminderEnabled ? Int(reminderDays) : nil
        )
        latestOrder = order(for: newCase)
        cases.insert(newCase, at: 0)
        let evicted = cases.dropFirst(75)
        DumbLocalNotifications.cancel(identifiers: evicted.map(notificationIdentifier))
        cases = Array(cases.prefix(75))
        persistCases()

        if reminderEnabled { scheduleReminder(for: newCase) }
        clearDraft(keepOrder: true)
    }

    private func order(for sockCase: SockCase) -> String {
        let days = missingDays(for: sockCase)
        let stage: String
        switch days {
        case 0:
            stage = "Intake opened today. Interview the laundry basket before making allegations."
        case 1...3:
            stage = "Active search authorized. Check the hamper, fitted-sheet corners, and the floor behind the machine."
        case 4...14:
            stage = "Cold laundry case. Preserve hope, but stop searching the same dryer drum."
        default:
            stage = "Presumed independent for comedy purposes. The case remains open until you decide otherwise."
        }
        return "ORDER — \(sockCase.sockName), \(sockCase.color.lowercased()) and \(sockCase.pattern.lowercased()), missing \(days) \(days == 1 ? "day" : "days"). \(stage)"
    }

    private func resolve(_ sockCase: SockCase, as status: SockCaseStatus) {
        guard let index = cases.firstIndex(where: { $0.id == sockCase.id }) else { return }
        cases[index].status = status
        cases[index].resolvedAt = Date()
        DumbLocalNotifications.cancel(identifier: notificationIdentifier(sockCase))
        latestOrder = status == .reunited
            ? "CASE \(caseNumber(sockCase)) — Pair reunited. The court recognizes the return of \(sockCase.sockName)."
            : "CASE \(caseNumber(sockCase)) — Closed unsolved by your instruction. No machine was convicted."
        persistCases()
    }

    private func reopen(_ sockCase: SockCase) {
        guard let index = cases.firstIndex(where: { $0.id == sockCase.id }) else { return }
        cases[index].status = .open
        cases[index].resolvedAt = nil
        latestOrder = "CASE \(caseNumber(sockCase)) — Search reopened. Previous closure has been dramatically overturned."
        persistCases()
        if cases[index].reminderDays != nil { scheduleReminder(for: cases[index]) }
    }

    private func delete(_ sockCase: SockCase) {
        DumbLocalNotifications.cancel(identifier: notificationIdentifier(sockCase))
        cases.removeAll { $0.id == sockCase.id }
        latestOrder = cases.isEmpty ? Self.waitingOrder : "Case deleted by court order."
        persistCases()
    }

    private func clearDraft() {
        clearDraft(keepOrder: false)
    }

    private func clearDraft(keepOrder: Bool) {
        sockName = ""
        color = "Black"
        pattern = "Plain"
        lastSeen = ""
        missingSinceTimestamp = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
        reminderEnabled = false
        reminderDays = 3
        notificationMessage = "Off. The court will not contact you."
        if !keepOrder { latestOrder = Self.waitingOrder }
    }

    private func eraseAll() {
        DumbLocalNotifications.cancel(identifiers: cases.map(notificationIdentifier))
        cases = []
        showAllCases = false
        clearDraft()
        persistCases()
    }

    private func missingDays(for sockCase: SockCase) -> Int {
        daysBetween(sockCase.missingSince, Date())
    }

    private func daysBetween(_ start: Date, _ end: Date) -> Int {
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: start)
        let endDay = calendar.startOfDay(for: end)
        return max(0, calendar.dateComponents([.day], from: startDay, to: endDay).day ?? 0)
    }

    private func caseNumber(_ sockCase: SockCase) -> String {
        String(sockCase.id.uuidString.prefix(6))
    }

    private func notificationIdentifier(_ sockCase: SockCase) -> String {
        "sock-case-recheck-\(sockCase.id.uuidString)"
    }

    private func scheduleReminder(for sockCase: SockCase) {
        guard let days = sockCase.reminderDays else { return }
        Task {
            let proposed = Calendar.autoupdatingCurrent.date(byAdding: .day, value: days, to: Date()) ?? Date()
            let result = await DumbLocalNotifications.scheduleOneShot(
                identifier: notificationIdentifier(sockCase),
                title: "The Sock Tribunal reconvenes",
                body: "A missing-sock case is due for another look.",
                proposedDate: proposed
            )
            await MainActor.run {
                switch result {
                case .scheduled(let fireDate):
                    notificationMessage = "Recheck scheduled for \(fireDate.formatted(date: .abbreviated, time: .shortened))."
                case .denied:
                    notificationMessage = "Reminder not scheduled. Notifications are disabled in Settings."
                case .failed:
                    notificationMessage = "The reminder could not be scheduled. Filing still worked."
                }
            }
        }
    }

    private func refreshNotificationStatus() {
        guard reminderEnabled else {
            notificationMessage = "Off. The court will not contact you."
            return
        }
        Task {
            let status = await DumbLocalNotifications.authorization()
            await MainActor.run {
                switch status {
                case .available:
                    notificationMessage = "Notifications are available. Filing schedules one quiet-hours-aware recheck."
                case .notDetermined:
                    notificationMessage = "We’ll ask before turning this reminder on."
                case .denied:
                    notificationMessage = "Notifications are disabled in Settings; filing still works without one."
                }
            }
        }
    }

    private func restoreCases() {
        guard !hasLoaded else { return }
        hasLoaded = true
        guard
            let data = storedCases.data(using: .utf8),
            let decoded = try? JSONDecoder().decode([SockCase].self, from: data)
        else { return }
        cases = decoded
    }

    private func persistCases() {
        guard
            let data = try? JSONEncoder().encode(cases),
            let encoded = String(data: data, encoding: .utf8)
        else { return }
        storedCases = encoded
    }
}

#if canImport(PreviewsMacros)
#Preview { SockTribunalView() }
#endif
