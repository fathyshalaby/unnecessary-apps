import SwiftUI
import DumbKit

private struct PurchaseRecord: Codable, Identifiable {
    let id: UUID
    let purchaseName: String
    let amountCents: Int
    let category: String
    let intendedUses: Int
    let planned: Bool
    let reminderDays: Int?
    let report: String
    let date: Date

    init(
        purchaseName: String,
        amountCents: Int,
        category: String,
        intendedUses: Int,
        planned: Bool,
        reminderDays: Int?,
        report: String,
        date: Date = Date()
    ) {
        id = UUID()
        self.purchaseName = purchaseName
        self.amountCents = amountCents
        self.category = category
        self.intendedUses = intendedUses
        self.planned = planned
        self.reminderDays = reminderDays
        self.report = report
        self.date = date
    }
}

struct ReceiptDamageView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private static let emptyReport = "Enter a real purchase. The emotional invoice desk is open."

    @AppStorage("receiptDamage.amount") private var amount = ""
    @AppStorage("receiptDamage.purchaseName") private var purchaseName = ""
    @AppStorage("receiptDamage.category") private var category = "Food & drink"
    @AppStorage("receiptDamage.intendedUses") private var intendedUses = 10.0
    @AppStorage("receiptDamage.planned") private var planned = true
    @AppStorage("receiptDamage.reminderEnabled") private var reminderEnabled = false
    @AppStorage("receiptDamage.reminderDays") private var reminderDays = 7.0
    @AppStorage("receiptDamage.report") private var report = Self.emptyReport
    @AppStorage("receiptDamage.history") private var storedHistory = "[]"

    @State private var history: [PurchaseRecord] = []
    @State private var hasLoaded = false
    @State private var showAllHistory = false
    @State private var showEraseConfirmation = false
    @State private var notificationMessage = "Off. Enable a follow-up only when you want one."
    private let reminderConsentCopy = "We’ll ask before turning this reminder on."

    private let categories = ["Food & drink", "Clothing", "Home", "Tech", "Entertainment", "Other"]
    private let accent = CorpPalette.warningRed

    var body: some View {
        DumbShell(
            eyebrow: "RECEIPT DAMAGE",
            title: "How bad was it?",
            subtitle: "A cost-per-use reflection wearing a tiny courtroom wig.",
            accent: accent,
            personality: .dramatic
        ) {
            purchaseEditor

            DumbAction(
                title: "Issue & file emotional invoice",
                accent: accent,
                systemImage: "gavel.fill",
                action: issueReport
            )
            .disabled(parsedAmountCents == nil)
            .accessibilityIdentifier("issueReportButton")

            receiptPaper

            boundaryCard
            summaryCard

            Button(action: resetCurrentReceipt) {
                Label("Expunge current receipt", systemImage: "arrow.counterclockwise")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(!hasCurrentReceipt)
            .accessibilityIdentifier("clearReceiptButton")
            .accessibilityHint("Clears the current purchase without deleting filed history.")

            historyCard

            Button {
                showEraseConfirmation = true
            } label: {
                Label("Erase the receipt ledger", systemImage: "trash.fill")
                    .font(.subheadline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundStyle(accent)
            .buttonStyle(DumbPressStyle())
            .disabled(history.isEmpty && !hasCurrentReceipt)
            .accessibilityIdentifier("erasePurchaseDataButton")
        }
        .onAppear {
            restoreHistory()
            refreshNotificationStatus()
        }
        .onChange(of: amount) { _, _ in invalidateReport() }
        .onChange(of: purchaseName) { _, _ in invalidateReport() }
        .onChange(of: category) { _, _ in invalidateReport() }
        .onChange(of: intendedUses) { _, _ in invalidateReport() }
        .onChange(of: planned) { _, _ in invalidateReport() }
        .onChange(of: reminderEnabled) { _, enabled in
            invalidateReport()
            if enabled { refreshNotificationStatus() }
        }
        .onChange(of: reminderDays) { _, _ in invalidateReport() }
        .confirmationDialog(
            "Erase the current receipt and complete ledger?",
            isPresented: $showEraseConfirmation,
            titleVisibility: .visible
        ) {
            Button("Confirm erase the receipt ledger", role: .destructive, action: eraseAllData)
            Button("Keep the evidence", role: .cancel) {}
        } message: {
            Text("This erases every purchase reflection. It cannot be undone.")
        }
    }

    private var boundaryCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 7) {
                DumbStatusPill(
                    "PUBLISHED ARITHMETIC",
                    systemImage: "divide.circle.fill",
                    accent: accent
                )
                Text("Your math, not a moral score. We divide the price by the number of uses you plan.")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CorpPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var receiptPaper: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("EMOTIONAL INVOICE")
                        .font(.caption.weight(.black).monospaced())
                        .tracking(1.4)
                    Text("UNNECESSARY AUDIT COPY")
                        .font(.caption2.weight(.bold).monospaced())
                        .foregroundStyle(CorpPalette.mutedInk)
                }
                Spacer()
                Image(systemName: "barcode")
                    .font(.title2.weight(.black))
                    .foregroundStyle(accent)
                    .accessibilityHidden(true)
            }

            Rectangle()
                .fill(accent)
                .frame(height: 2)

            Text(report)
                .font(.system(.subheadline, design: .monospaced).weight(.bold))
                .foregroundStyle(CorpPalette.ink)
                .fixedSize(horizontal: false, vertical: true)
                .contentTransition(.opacity)

            HStack {
                Text("YOUR NUMBERS")
                Spacer()
                Text("TINY DRAMA")
            }
            .font(.caption2.weight(.black).monospaced())
            .foregroundStyle(CorpPalette.mutedInk)

            HStack(spacing: 6) {
                ForEach(0..<28, id: \.self) { _ in
                    Circle()
                        .fill(CorpPalette.canvas)
                        .frame(width: 5, height: 5)
                }
            }
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
        }
        .padding(20)
        .background(CorpPalette.receiptCream, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(accent.opacity(0.45), lineWidth: 2)
        )
        .shadow(color: CorpPalette.ink.opacity(0.12), radius: 0, x: 3, y: 5)
        .rotationEffect(.degrees(report == Self.emptyReport ? 0 : -0.35))
        .animation(reduceMotion ? nil : .snappy, value: report)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Emotional invoice")
        .accessibilityValue(report)
        .accessibilityIdentifier("receiptDamageResult")
    }

    private var summaryCard: some View {
        DumbCard(accent: accent, isSelected: !history.isEmpty) {
            HStack(spacing: 10) {
                summaryMetric(value: "\(history.count)", label: "filed")
                Divider()
                summaryMetric(value: formatCompactMoney(totalCents), label: "logged")
                Divider()
                summaryMetric(value: "\(impulseCount)", label: "impulse")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("purchaseLedgerSummary")
        .accessibilityLabel("Purchase reflection summary")
        .accessibilityValue("\(history.count) filed, \(formatMoney(totalCents)) logged, \(impulseCount) marked impulse")
    }

    private func summaryMetric(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.title3.weight(.black))
                .foregroundStyle(accent)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(label.uppercased())
                .font(.caption2.weight(.black))
                .tracking(0.6)
                .foregroundStyle(CorpPalette.mutedInk)
        }
        .frame(maxWidth: .infinity)
    }

    private var purchaseEditor: some View {
        DumbCard(accent: accent, isSelected: parsedAmountCents != nil) {
            VStack(alignment: .leading, spacing: 14) {
                Text("ENTER THE EVIDENCE")
                    .font(.caption2.weight(.black))
                    .tracking(1.2)
                    .foregroundStyle(CorpPalette.mutedInk)
                DumbField("Purchase name (optional)", maxLength: 100, text: $purchaseName)
                DumbField("Amount in EUR", maxLength: 18, text: $amount)

                validationText

                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.menu)
                .font(.body.weight(.bold))
                .tint(accent)
                .accessibilityIdentifier("receiptCategoryPicker")

                DumbSlider(
                    title: "Intended uses",
                    value: $intendedUses,
                    range: 1...100,
                    step: 1,
                    accent: accent
                )

                Toggle(isOn: $planned) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("This purchase was planned")
                            .font(.subheadline.weight(.black))
                            .foregroundStyle(CorpPalette.ink)
                        Text("Choose the label that fits best.")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CorpPalette.mutedInk)
                    }
                }
                .tint(accent)
                .accessibilityIdentifier("plannedPurchaseToggle")

                Divider()

                Toggle(isOn: $reminderEnabled) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Remind me to review this purchase")
                            .font(.subheadline.weight(.black))
                            .foregroundStyle(CorpPalette.ink)
                        Text("We’ll ask before turning this reminder on.")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CorpPalette.mutedInk)
                    }
                }
                .tint(accent)
                .accessibilityIdentifier("purchaseReminderToggle")

                if reminderEnabled {
                    DumbSlider(
                        title: "Review reminder in days",
                        value: $reminderDays,
                        range: 1...30,
                        step: 1,
                        accent: accent
                    )
                    Text(notificationMessage)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("purchaseNotificationStatus")
                }
            }
        }
    }

    @ViewBuilder
    private var validationText: some View {
        if amount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Text("Enter a positive EUR amount. Decimal commas or points are accepted.")
                .font(.caption.weight(.bold))
                .foregroundStyle(CorpPalette.mutedInk)
                .accessibilityIdentifier("receiptAmountValidation")
        } else if let cents = parsedAmountCents {
            Text("Parsed amount: \(formatMoney(cents))")
                .font(.caption.weight(.black))
                .foregroundStyle(accent)
                .accessibilityIdentifier("receiptAmountValidation")
                .accessibilityValue("Valid amount \(formatMoney(cents))")
        } else {
            Text("Enter a positive amount up to €1,000,000 using digits and one decimal separator.")
                .font(.caption.weight(.black))
                .foregroundStyle(accent)
                .accessibilityIdentifier("receiptAmountValidation")
                .accessibilityValue("Invalid amount")
        }
    }

    private var historyCard: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 11) {
                HStack {
                    Text("RECEIPT LEDGER")
                        .font(.caption2.weight(.black))
                        .tracking(1.2)
                        .foregroundStyle(CorpPalette.mutedInk)
                    Spacer()
                    Text("\(history.count) purchases")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .accessibilityIdentifier("purchaseHistoryCount")
                        .accessibilityValue("\(history.count)")
                }

                if history.isEmpty {
                    Label("No purchase has entered evidence.", systemImage: "receipt")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(CorpPalette.ink)
                        .accessibilityIdentifier("emptyPurchaseHistory")
                } else {
                    ForEach(visibleHistory) { purchase in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                DumbStatusPill(
                                    purchase.planned ? "PLANNED" : "IMPULSE",
                                    systemImage: purchase.planned ? "checkmark.circle.fill" : "bolt.fill",
                                    accent: accent
                                )
                                Spacer()
                                Text(purchase.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(CorpPalette.mutedInk)
                            }
                            Text(purchase.purchaseName.isEmpty ? "Unnamed purchase" : purchase.purchaseName)
                                .font(.headline.weight(.black))
                                .foregroundStyle(CorpPalette.ink)
                            Text("\(formatMoney(purchase.amountCents)) · \(purchase.category)")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(CorpPalette.ink)
                            Text("\(purchase.intendedUses) intended uses · \(formatMoney(costPerUseCents(purchase))) per intended use")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(CorpPalette.mutedInk)
                            if let reminderDays = purchase.reminderDays {
                                Label("Review requested: \(reminderDays) \(reminderDays == 1 ? "day" : "days")", systemImage: "bell.fill")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(CorpPalette.mutedInk)
                            }
                            Button(role: .destructive) {
                                delete(purchase)
                            } label: {
                                Label("Delete purchase reflection", systemImage: "trash")
                                    .font(.caption.weight(.black))
                            }
                            .accessibilityIdentifier("deletePurchaseRecordButton")
                        }
                        .padding(.vertical, 3)
                    }

                    if history.count > 5 {
                        Button(showAllHistory ? "Show newest five" : "Browse all \(history.count)") {
                            withAnimation(reduceMotion ? nil : .snappy) { showAllHistory.toggle() }
                        }
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(accent)
                        .accessibilityIdentifier("togglePurchaseHistoryButton")
                    }
                }
            }
        }
    }

    private var visibleHistory: [PurchaseRecord] {
        showAllHistory ? history : Array(history.prefix(5))
    }

    private var totalCents: Int {
        history.reduce(0) { $0 + $1.amountCents }
    }

    private var impulseCount: Int {
        history.filter { !$0.planned }.count
    }

    private var parsedAmountCents: Int? {
        var normalized = amount.trimmingCharacters(in: .whitespacesAndNewlines)
        normalized.removeAll { $0 == "€" || $0 == " " || $0 == "\u{00A0}" || $0 == "'" }

        if let comma = normalized.lastIndex(of: ","), let dot = normalized.lastIndex(of: ".") {
            if comma > dot {
                normalized.removeAll { $0 == "." }
                normalized = normalized.replacingOccurrences(of: ",", with: ".")
            } else {
                normalized.removeAll { $0 == "," }
            }
        } else {
            normalized = normalized.replacingOccurrences(of: ",", with: ".")
        }

        guard normalized.filter({ $0 == "." }).count <= 1 else { return nil }
        guard normalized.allSatisfy({ $0.isNumber || $0 == "." }) else { return nil }
        guard let value = Double(normalized), value > 0, value <= 1_000_000 else { return nil }
        return Int((value * 100).rounded())
    }

    private var hasCurrentReceipt: Bool {
        !amount.isEmpty
            || !purchaseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || category != "Food & drink"
            || intendedUses != 10
            || !planned
            || reminderEnabled
            || reminderDays != 7
            || report != Self.emptyReport
    }

    private func issueReport() {
        guard let cents = parsedAmountCents else { return }
        let uses = Int(intendedUses)
        let perUse = roundedCostPerUse(amountCents: cents, intendedUses: uses)
        let name = purchaseName.trimmingCharacters(in: .whitespacesAndNewlines)
        let intent = planned ? "marked planned" : "marked impulse"
        let generated = "EMOTIONAL INVOICE — \(name.isEmpty ? "Unnamed purchase" : name). \(formatMoney(cents)) in \(category). Planned-use math: \(formatMoney(cents)) ÷ \(uses) = \(formatMoney(perUse)) per intended use, rounded to cents. Purchase context: \(intent) by you. Your math, your label, your tiny drama—not financial advice."
        report = generated
        let purchase = PurchaseRecord(
            purchaseName: name,
            amountCents: cents,
            category: category,
            intendedUses: uses,
            planned: planned,
            reminderDays: reminderEnabled ? Int(reminderDays) : nil,
            report: generated
        )
        history.insert(purchase, at: 0)
        let evictedPurchases = history.dropFirst(50)
        evictedPurchases.forEach(cancelReminder)
        history = Array(history.prefix(50))
        persistHistory()
        if reminderEnabled {
            scheduleReminder(for: purchase)
        }
    }

    private func roundedCostPerUse(amountCents: Int, intendedUses: Int) -> Int {
        Int((Double(amountCents) / Double(intendedUses)).rounded())
    }

    private func costPerUseCents(_ purchase: PurchaseRecord) -> Int {
        roundedCostPerUse(amountCents: purchase.amountCents, intendedUses: purchase.intendedUses)
    }

    private func formatMoney(_ cents: Int) -> String {
        String(format: "€%.2f", Double(cents) / 100)
    }

    private func formatCompactMoney(_ cents: Int) -> String {
        if cents >= 100_000 {
            return String(format: "€%.1fk", Double(cents) / 100_000)
        }
        return formatMoney(cents)
    }

    private func invalidateReport() {
        guard report != Self.emptyReport else { return }
        report = "Purchase changed. Issue a fresh emotional invoice."
    }

    private func resetCurrentReceipt() {
        amount = ""
        purchaseName = ""
        category = "Food & drink"
        intendedUses = 10
        planned = true
        reminderEnabled = false
        reminderDays = 7
        notificationMessage = "Off. Enable a follow-up only when you want one."
        report = Self.emptyReport
    }

    private func delete(_ purchase: PurchaseRecord) {
        cancelReminder(for: purchase)
        history.removeAll { $0.id == purchase.id }
        persistHistory()
    }

    private func eraseAllData() {
        let identifiers = history.map { notificationIdentifier(for: $0) }
        DumbLocalNotifications.cancel(identifiers: identifiers)
        history = []
        showAllHistory = false
        resetCurrentReceipt()
        persistHistory()
    }

    private func notificationIdentifier(for purchase: PurchaseRecord) -> String {
        "purchase-review-\(purchase.id.uuidString)"
    }

    private func scheduleReminder(for purchase: PurchaseRecord) {
        guard let days = purchase.reminderDays else { return }
        Task {
            let proposed = Calendar.autoupdatingCurrent.date(byAdding: .day, value: days, to: Date()) ?? Date()
            let result = await DumbLocalNotifications.scheduleOneShot(
                identifier: notificationIdentifier(for: purchase),
                title: "The receipt requests a follow-up",
                body: "A purchase reflection is ready for review.",
                proposedDate: proposed
            )
            await MainActor.run {
                switch result {
                case .scheduled(let fireDate):
                    notificationMessage = "Scheduled for \(fireDate.formatted(date: .abbreviated, time: .shortened))."
                case .denied:
                    notificationMessage = "Reminder not scheduled. Notifications are disabled in Settings."
                case .failed:
                    notificationMessage = "The reminder could not be scheduled. Try again after checking Settings."
                }
            }
        }
    }

    private func cancelReminder(for purchase: PurchaseRecord) {
        DumbLocalNotifications.cancel(identifier: notificationIdentifier(for: purchase))
    }

    private func refreshNotificationStatus() {
        guard reminderEnabled else {
            notificationMessage = "Off. Enable a follow-up only when you want one."
            return
        }
        notificationMessage = reminderConsentCopy
        Task {
            let status = await DumbLocalNotifications.authorization()
            await MainActor.run {
                switch status {
                case .available:
                    notificationMessage = "\(reminderConsentCopy) Notifications are available; filing schedules one quiet-hours-aware reminder."
                case .notDetermined:
                    notificationMessage = reminderConsentCopy
                case .denied:
                    notificationMessage = "\(reminderConsentCopy) Notifications are disabled in Settings; filing still works without one."
                }
            }
        }
    }

    private func restoreHistory() {
        guard !hasLoaded else { return }
        hasLoaded = true
        guard
            let data = storedHistory.data(using: .utf8),
            let saved = try? JSONDecoder().decode([PurchaseRecord].self, from: data)
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

#if canImport(PreviewsMacros)
#Preview { ReceiptDamageView() }
#endif
