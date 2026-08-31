@preconcurrency import CoreLocation
import MapKit
import Observation
import SwiftUI
import DumbKit

private struct LooCoordinate: Codable, Hashable {
    let latitude: Double
    let longitude: Double

    init(_ coordinate: CLLocationCoordinate2D) {
        latitude = coordinate.latitude
        longitude = coordinate.longitude
    }

    var clLocationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

private struct LooReport: Codable, Identifiable, Hashable {
    let id: UUID
    let createdAt: Date
    let coordinate: LooCoordinate
    var name: String
    var cleanliness: Int
    var privacy: Int
    var supplies: Int
    var queue: Int
    var changingTableObserved: Bool
    var note: String

    var qualityIndex: Int {
        let queueRelief = 10 - queue
        return Int((Double(cleanliness + privacy + supplies + queueRelief) / 4).rounded())
    }
}

private struct LooPlace: Identifiable, Hashable {
    let id: String
    let name: String
    let address: String
    let coordinate: LooCoordinate

    init(name: String, address: String, coordinate: CLLocationCoordinate2D) {
        self.name = name
        self.address = address
        self.coordinate = LooCoordinate(coordinate)
        id = "\(name)|\(coordinate.latitude)|\(coordinate.longitude)"
    }
}

private struct LooDraft: Identifiable {
    let id = UUID()
    let suggestedName: String
    let coordinate: LooCoordinate
    let existingReport: LooReport?

    init(suggestedName: String, coordinate: LooCoordinate, existingReport: LooReport? = nil) {
        self.suggestedName = suggestedName
        self.coordinate = coordinate
        self.existingReport = existingReport
    }
}

@MainActor
@Observable
private final class LooReportStore {
    private static let storageKey = "bathroomMap.reports.v2"
    private static let maximumReports = 100

    @ObservationIgnored private let defaults: UserDefaults
    private(set) var reports: [LooReport]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        guard
            let data = defaults.data(forKey: Self.storageKey),
            let decoded = try? JSONDecoder().decode([LooReport].self, from: data)
        else {
            reports = []
            return
        }
        reports = Array(decoded.prefix(Self.maximumReports))
    }

    func add(
        coordinate: LooCoordinate,
        name: String,
        cleanliness: Int,
        privacy: Int,
        supplies: Int,
        queue: Int,
        changingTableObserved: Bool,
        note: String
    ) {
        let report = LooReport(
            id: UUID(),
            createdAt: .now,
            coordinate: coordinate,
            name: name,
            cleanliness: cleanliness,
            privacy: privacy,
            supplies: supplies,
            queue: queue,
            changingTableObserved: changingTableObserved,
            note: note
        )
        reports.insert(report, at: 0)
        reports = Array(reports.prefix(Self.maximumReports))
        persist()
    }

    func update(
        id: UUID,
        coordinate: LooCoordinate,
        name: String,
        cleanliness: Int,
        privacy: Int,
        supplies: Int,
        queue: Int,
        changingTableObserved: Bool,
        note: String
    ) {
        guard let index = reports.firstIndex(where: { $0.id == id }) else { return }
        let existing = reports[index]
        reports[index] = LooReport(
            id: id,
            createdAt: existing.createdAt,
            coordinate: coordinate,
            name: name,
            cleanliness: cleanliness,
            privacy: privacy,
            supplies: supplies,
            queue: queue,
            changingTableObserved: changingTableObserved,
            note: note
        )
        persist()
    }

    func remove(id: UUID) {
        reports.removeAll { $0.id == id }
        persist()
    }

    func removeAll() {
        reports.removeAll()
        defaults.removeObject(forKey: Self.storageKey)
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(reports) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }
}

@MainActor
@Observable
private final class LooSearchService {
    @ObservationIgnored private var activeSearch: MKLocalSearch?

    private(set) var results: [LooPlace] = []
    private(set) var isSearching = false
    private(set) var statusMessage = "Move the map, then search that area for public restrooms."

    func search(region: MKCoordinateRegion) async {
        activeSearch?.cancel()
        isSearching = true
        statusMessage = "Asking Apple Maps about nearby facilities…"

        let request = MKLocalSearch.Request(naturalLanguageQuery: "public restroom", region: region)
        request.resultTypes = .pointOfInterest
        let search = MKLocalSearch(request: request)
        activeSearch = search

        do {
            let response = try await search.start()
            guard activeSearch === search else { return }
            results = response.mapItems.prefix(12).compactMap { item in
                guard let name = item.name, !name.isEmpty else { return nil }
                return LooPlace(
                    name: name,
                    address: item.placemark.title ?? "Address unavailable",
                    coordinate: item.placemark.coordinate
                )
            }
            statusMessage = results.isEmpty
                ? "Apple Maps found no restrooms here. Pan somewhere else or drop a pin."
                : "Found \(results.count) possible facilit\(results.count == 1 ? "y" : "ies"). Confirm access and opening hours yourself."
        } catch is CancellationError {
            return
        } catch {
            guard activeSearch === search else { return }
            results = []
            statusMessage = "Restroom search is taking a break. Drop a pin instead."
        }

        if activeSearch === search {
            activeSearch = nil
            isSearching = false
        }
    }
}

@MainActor
@Observable
private final class LooLocationService: NSObject, @preconcurrency CLLocationManagerDelegate {
    @ObservationIgnored private let manager = CLLocationManager()
    @ObservationIgnored private var shouldRequestLocationAfterAuthorization = false

    private(set) var lastCoordinate: LooCoordinate?
    private(set) var statusMessage = "Search nearby or move the pin to a place you visited."
    private(set) var isWorking = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestCurrentLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            statusMessage = "Location Services are off. Pan the map to continue."
            return
        }

        switch manager.authorizationStatus {
        case .notDetermined:
            shouldRequestLocationAfterAuthorization = true
            isWorking = true
            statusMessage = "Waiting for your location choice…"
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            isWorking = true
            statusMessage = "Looking for your current map area…"
            manager.requestLocation()
        case .denied, .restricted:
            isWorking = false
            statusMessage = "Location is unavailable. Pan the map to choose an area instead."
        @unknown default:
            isWorking = false
            statusMessage = "Location status is unknown. Pan the map to continue."
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            guard shouldRequestLocationAfterAuthorization else { return }
            shouldRequestLocationAfterAuthorization = false
            isWorking = true
            manager.requestLocation()
        case .denied, .restricted:
            shouldRequestLocationAfterAuthorization = false
            isWorking = false
            statusMessage = "Location was not granted. Search the visible map area instead."
        case .notDetermined:
            break
        default:
            shouldRequestLocationAfterAuthorization = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        isWorking = false
        guard let location = locations.last else {
            statusMessage = "No position arrived. Pan the map to continue."
            return
        }
        lastCoordinate = LooCoordinate(location.coordinate)
        statusMessage = "Map centered. Move the pin if the porcelain intelligence is slightly off."
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isWorking = false
        statusMessage = "Could not get a position. Pan the map to continue."
    }
}

struct BathroomMapView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private static let regionStorageKey = "bathroomMap.region"
    private static let initialRegion = MapJournalRegionStore.load(storageKey: regionStorageKey)

    @State private var store = LooReportStore()
    @State private var searchService = LooSearchService()
    @State private var locationService = LooLocationService()
    @State private var cameraPosition: MapCameraPosition = .region(initialRegion)
    @State private var visibleRegion = initialRegion
    @State private var mapCenter = LooCoordinate(initialRegion.center)
    @State private var presentedDraft: LooDraft?
    @State private var showClearConfirmation = false

    private let accent = CorpPalette.bathroomBlue

    var body: some View {
        ZStack {
            CorpPalette.canvas.ignoresSafeArea()
            VStack(spacing: 0) {
                brandHeader
                mapCard
                reportDesk
            }
        }
        .tint(accent)
        .environment(\.dumbExperienceStyle, .map)
        .sheet(item: $presentedDraft) { draft in
            LooEditorSheet(draft: draft) { name, cleanliness, privacy, supplies, queue, changingTableObserved, note in
                if let existing = draft.existingReport {
                    store.update(
                        id: existing.id,
                        coordinate: draft.coordinate,
                        name: name,
                        cleanliness: cleanliness,
                        privacy: privacy,
                        supplies: supplies,
                        queue: queue,
                        changingTableObserved: changingTableObserved,
                        note: note
                    )
                } else {
                    store.add(
                        coordinate: draft.coordinate,
                        name: name,
                        cleanliness: cleanliness,
                        privacy: privacy,
                        supplies: supplies,
                        queue: queue,
                        changingTableObserved: changingTableObserved,
                        note: note
                    )
                }
            }
        }
        .confirmationDialog(
            "Clear every bathroom report?",
            isPresented: $showClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("Clear all bathroom reports", role: .destructive) {
                store.removeAll()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This clears every bathroom report. It cannot be undone.")
        }
        .onChange(of: locationService.lastCoordinate) { _, coordinate in
            guard let coordinate else { return }
            mapCenter = coordinate
            visibleRegion = MKCoordinateRegion(
                center: coordinate.clLocationCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
            )
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.45)) {
                cameraPosition = .region(visibleRegion)
            }
        }
    }

    private var brandHeader: some View {
        HStack(alignment: .center, spacing: DumbSpacing.sm) {
            VStack(alignment: .leading, spacing: 2) {
                Text("CIVIC LOO INTELLIGENCE")
                    .font(.caption2.weight(.black))
                    .tracking(1.2)
                    .foregroundStyle(accent)
                Text("Bathroom Quality Map")
                    .font(.system(.title3, design: .rounded).weight(.black))
                    .foregroundStyle(CorpPalette.ink)
                    .lineLimit(1)
                    .accessibilityAddTraits(.isHeader)
                Text("Real map. Your notes. Inspect the lock yourself.")
                    .font(.caption)
                    .foregroundStyle(CorpPalette.mutedInk)
                    .lineLimit(2)
            }
            Spacer(minLength: DumbSpacing.xs)
            Image("AppMascot", bundle: .main)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .padding(5)
                .background(accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(accent.opacity(0.20), lineWidth: 1))
                .accessibilityHidden(true)
        }
        .padding(.horizontal, DumbSpacing.md)
        .padding(.top, DumbSpacing.sm)
        .padding(.bottom, DumbSpacing.sm)
    }

    private var mapCard: some View {
        Map(position: $cameraPosition) {
            UserAnnotation()
            ForEach(searchService.results) { place in
                Marker(place.name, systemImage: "figure.dress.line.vertical.figure", coordinate: place.coordinate.clLocationCoordinate)
                    .tint(CorpPalette.coral)
            }
            ForEach(store.reports) { report in
                Marker(report.name, systemImage: "checkmark.seal.fill", coordinate: report.coordinate.clLocationCoordinate)
                    .tint(accent)
            }
        }
        .mapStyle(.standard(elevation: .flat, pointsOfInterest: .all, showsTraffic: false))
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        .onMapCameraChange(frequency: .onEnd) { context in
            visibleRegion = context.region
            mapCenter = LooCoordinate(context.region.center)
            MapJournalRegionStore.save(context.region, storageKey: Self.regionStorageKey)
        }
        .overlay {
            MapJournalCrosshair(accent: accent)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                locationService.requestCurrentLocation()
            } label: {
                Group {
                    if locationService.isWorking {
                        ProgressView()
                    } else {
                        Image(systemName: "location.fill")
                    }
                }
                .font(.headline.weight(.black))
                .frame(width: DumbMetrics.minimumTapTarget, height: DumbMetrics.minimumTapTarget)
                .background(CorpPalette.surface.opacity(0.94), in: Circle())
                .shadow(color: .black.opacity(0.10), radius: 3, y: 2)
            }
            .disabled(locationService.isWorking)
            .accessibilityLabel("Use my location")
            .accessibilityHint("Requests location only to center the restroom map near you.")
            .accessibilityIdentifier("useBathroomLocationButton")
            .padding(12)
        }
        .overlay(alignment: .bottom) {
            HStack(spacing: 9) {
                Button {
                    Task { await searchService.search(region: visibleRegion) }
                } label: {
                    Group {
                        if searchService.isSearching {
                            ProgressView().tint(CorpPalette.actionInk)
                        } else {
                            Label("Find restrooms", systemImage: "magnifyingglass")
                        }
                    }
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(CorpPalette.actionInk)
                    .frame(maxWidth: .infinity, minHeight: DumbMetrics.minimumTapTarget)
                    .background(accent, in: Capsule())
                }
                .disabled(searchService.isSearching)
                .buttonStyle(DumbPressStyle())
                .accessibilityIdentifier("findBathroomsButton")

                Button {
                    presentedDraft = LooDraft(suggestedName: "", coordinate: mapCenter)
                } label: {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.headline.weight(.black))
                        .foregroundStyle(accent)
                        .frame(width: DumbMetrics.minimumTapTarget, height: DumbMetrics.minimumTapTarget)
                        .background(CorpPalette.surface.opacity(0.94), in: Circle())
                }
                .buttonStyle(DumbPressStyle())
                .accessibilityLabel("Report the place under the center marker")
                .accessibilityIdentifier("reportBathroomMapCenterButton")
            }
            .padding(.horizontal, DumbSpacing.sm)
            .padding(.bottom, DumbSpacing.sm)
        }
        .frame(height: 360)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(CorpPalette.ink.opacity(0.08), lineWidth: 1))
        .padding(.horizontal, DumbSpacing.sm)
    }

    private var reportDesk: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: DumbSpacing.sm) {
                statusStrip

                if !searchService.results.isEmpty {
                    searchResults
                }

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.reports.isEmpty ? "No reports yet" : "\(store.reports.count) bathroom report\(store.reports.count == 1 ? "" : "s") on file")
                            .font(.headline.weight(.black))
                            .foregroundStyle(CorpPalette.ink)
                        Text("Filed for your next emergency.")
                            .font(.caption)
                            .foregroundStyle(CorpPalette.mutedInk)
                    }
                    Spacer()
                    if !store.reports.isEmpty {
                        Button("Clear all", role: .destructive) {
                            showClearConfirmation = true
                        }
                        .font(.caption.weight(.bold))
                        .accessibilityIdentifier("clearBathroomReportsButton")
                    }
                }

                if store.reports.isEmpty {
                    emptyState
                } else {
                    ForEach(store.reports) { report in
                        LooReportCard(report: report, accent: accent) {
                            visibleRegion = MKCoordinateRegion(
                                center: report.coordinate.clLocationCoordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.006)
                            )
                            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) {
                                cameraPosition = .region(visibleRegion)
                            }
                        } onEdit: {
                            presentedDraft = LooDraft(
                                suggestedName: report.name,
                                coordinate: report.coordinate,
                                existingReport: report
                            )
                        } onDelete: {
                            store.remove(id: report.id)
                        }
                    }
                }
            }
            .padding(.horizontal, DumbSpacing.md)
            .padding(.top, DumbSpacing.sm)
            .padding(.bottom, DumbSpacing.lg)
        }
        .scrollIndicators(.hidden)
    }

    private var statusStrip: some View {
        VStack(alignment: .leading, spacing: 5) {
            Label(searchService.statusMessage, systemImage: "figure.wave")
            Label(locationService.statusMessage, systemImage: "location.circle.fill")
            Label("Not an emergency or accessibility service. Verify access, hours, and conditions on arrival.", systemImage: "exclamationmark.triangle.fill")
        }
        .font(.caption)
        .foregroundStyle(CorpPalette.mutedInk)
        .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, DumbSpacing.micro)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("bathroomMapStatus")
    }

    private var searchResults: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("POSSIBLE APPLE MAPS RESULTS")
                .font(.caption2.weight(.black))
                .tracking(1.1)
                .foregroundStyle(accent)
            ScrollView(.horizontal) {
                LazyHStack(spacing: 10) {
                    ForEach(searchService.results) { place in
                        Button {
                            presentedDraft = LooDraft(suggestedName: place.name, coordinate: place.coordinate)
                        } label: {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(place.name)
                                    .font(.subheadline.weight(.black))
                                    .foregroundStyle(CorpPalette.ink)
                                    .lineLimit(1)
                                Text(place.address)
                                    .font(.caption2)
                                    .foregroundStyle(CorpPalette.mutedInk)
                                    .lineLimit(2)
                                Label("File a report", systemImage: "square.and.pencil")
                                    .font(.caption2.weight(.black))
                                    .foregroundStyle(accent)
                            }
                            .frame(width: 188, alignment: .leading)
                            .padding(DumbSpacing.sm)
                            .background(CorpPalette.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(CorpPalette.ink.opacity(0.06), lineWidth: 1))
                        }
                        .buttonStyle(DumbPressStyle())
                        .accessibilityIdentifier("bathroomSearchResult")
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private var emptyState: some View {
        DumbEmptyInvite(
            title: "The loo bureau has no field reports",
            message: "Search the map or pin a place you visited. Do not trespass for bathroom journalism.",
            systemImage: "figure.wave",
            accent: accent
        )
        .accessibilityIdentifier("emptyBathroomLedger")
    }
}

private struct MapJournalCrosshair: View {
    let accent: Color

    var body: some View {
        ZStack {
            Rectangle()
                .fill(accent.opacity(0.88))
                .frame(width: 24, height: 2)
            Rectangle()
                .fill(accent.opacity(0.88))
                .frame(width: 2, height: 24)
            Circle()
                .fill(accent)
                .frame(width: 6, height: 6)
                .overlay(Circle().stroke(CorpPalette.surface, lineWidth: 1.5))
        }
        .shadow(color: .black.opacity(0.14), radius: 2, y: 1)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct LooReportCard: View {
    let report: LooReport
    let accent: Color
    let onShow: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(report.name)
                        .font(.headline.weight(.black))
                        .foregroundStyle(CorpPalette.ink)
                    Text(report.createdAt, format: .dateTime.day().month().hour().minute())
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(CorpPalette.mutedInk)
                }
                Spacer()
                Text("\(report.qualityIndex)/10")
                    .font(.system(.title3, design: .rounded).weight(.black))
                    .foregroundStyle(accent)
            }

            HStack(spacing: 7) {
                scorePill("Clean \(report.cleanliness)", icon: "sparkles")
                scorePill("Privacy \(report.privacy)", icon: "lock.fill")
                scorePill("Stock \(report.supplies)", icon: "shippingbox.fill")
            }

            if !report.note.isEmpty {
                Text(report.note)
                    .font(.subheadline)
                    .foregroundStyle(CorpPalette.mutedInk)
                    .lineLimit(3)
            }

            HStack {
                Label(
                    report.changingTableObserved ? "Changing table observed" : "Changing table unknown",
                    systemImage: report.changingTableObserved ? "checkmark.seal.fill" : "questionmark.circle.fill"
                )
                .font(.caption.weight(.bold))
                .foregroundStyle(CorpPalette.mutedInk)
                Spacer()
                Button("Show", action: onShow)
                    .font(.caption.weight(.black))
                Button("Edit", action: onEdit)
                    .font(.caption.weight(.black))
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                }
                .accessibilityLabel("Delete \(report.name)")
            }
        }
        .padding(DumbSpacing.md)
        .background(CorpPalette.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(CorpPalette.ink.opacity(0.06), lineWidth: 1))
        .accessibilityIdentifier("bathroomReportCard")
    }

    private func scorePill(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.caption2.weight(.black))
            .foregroundStyle(CorpPalette.ink.opacity(0.78))
            .lineLimit(1)
            .minimumScaleFactor(0.70)
            .padding(.horizontal, DumbSpacing.xs)
            .padding(.vertical, DumbSpacing.micro + 2)
            .background(accent.opacity(0.12), in: Capsule())
    }
}

private struct LooEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    let draft: LooDraft
    let onSave: (String, Int, Int, Int, Int, Bool, String) -> Void

    @State private var name: String
    @State private var cleanliness = 6.0
    @State private var privacy = 7.0
    @State private var supplies = 6.0
    @State private var queue = 3.0
    @State private var changingTableObserved = false
    @State private var note = ""
    @State private var validationMessage: String?

    private let accent = CorpPalette.bathroomBlue

    init(
        draft: LooDraft,
        onSave: @escaping (String, Int, Int, Int, Int, Bool, String) -> Void
    ) {
        self.draft = draft
        self.onSave = onSave
        let report = draft.existingReport
        _name = State(initialValue: report?.name ?? draft.suggestedName)
        _cleanliness = State(initialValue: Double(report?.cleanliness ?? 6))
        _privacy = State(initialValue: Double(report?.privacy ?? 7))
        _supplies = State(initialValue: Double(report?.supplies ?? 6))
        _queue = State(initialValue: Double(report?.queue ?? 3))
        _changingTableObserved = State(initialValue: report?.changingTableObserved ?? false)
        _note = State(initialValue: report?.note ?? "")
    }

    private var isEditing: Bool { draft.existingReport != nil }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    sourceTicket

                    DumbCard(accent: accent) {
                        VStack(alignment: .leading, spacing: 14) {
                            DumbField("Bathroom name", maxLength: 100, text: $name)
                                .accessibilityIdentifier("bathroomNameField")
                            ratingSlider("Cleanliness", value: $cleanliness, icon: "sparkles")
                            ratingSlider("Privacy", value: $privacy, icon: "lock.fill")
                            ratingSlider("Supplies", value: $supplies, icon: "shippingbox.fill")
                            ratingSlider("Queue length", value: $queue, icon: "person.2.fill")
                            Toggle("Changing table observed", isOn: $changingTableObserved)
                                .font(.subheadline.weight(.bold))
                                .tint(accent)
                                .accessibilityIdentifier("changingTableObservedToggle")
                        }
                    }

                    DumbCard(accent: accent) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("FIELD NOTE · OPTIONAL")
                                .font(.caption2.weight(.black))
                                .tracking(1.0)
                                .foregroundStyle(accent)
                            TextEditor(text: $note)
                                .frame(minHeight: 90)
                                .scrollContentBackground(.hidden)
                                .padding(8)
                                .background(CorpPalette.canvas.opacity(0.7), in: RoundedRectangle(cornerRadius: 14))
                                .accessibilityLabel("Bathroom note")
                                .accessibilityIdentifier("bathroomNoteField")
                                .onChange(of: note) { _, value in
                                    if value.count > 300 {
                                        note = String(value.prefix(300))
                                    }
                                }
                            Text("\(note.count)/300")
                                .font(.caption2.monospacedDigit())
                                .foregroundStyle(CorpPalette.mutedInk)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }

                    if let validationMessage {
                        Label(validationMessage, systemImage: "exclamationmark.triangle.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(CorpPalette.warningRed)
                            .accessibilityIdentifier("bathroomValidationMessage")
                    }

                    DumbAction(
                        title: isEditing ? "Update field report" : "Save field report",
                        accent: accent,
                        systemImage: "tray.and.arrow.down.fill",
                        action: save
                    )
                        .accessibilityIdentifier("saveBathroomReportButton")
                }
                .padding(18)
            }
            .background(CorpPalette.canvas.ignoresSafeArea())
            .navigationTitle(isEditing ? "Edit bathroom report" : "Bathroom field report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var sourceTicket: some View {
        HStack(spacing: 12) {
            Image(systemName: draft.suggestedName.isEmpty ? "mappin.and.ellipse" : "map.fill")
                .font(.title2.weight(.bold))
                .foregroundStyle(accent)
            VStack(alignment: .leading, spacing: 2) {
                Text(draft.suggestedName.isEmpty ? "YOUR MAP PIN" : "APPLE MAPS RESULT")
                    .font(.caption2.weight(.black))
                    .tracking(1.1)
                    .foregroundStyle(accent)
                Text("\(draft.coordinate.latitude, specifier: "%.5f"), \(draft.coordinate.longitude, specifier: "%.5f")")
                    .font(.caption.monospacedDigit().weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func ratingSlider(_ title: String, value: Binding<Double>, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.subheadline.weight(.bold))
                Spacer()
                Text("\(Int(value.wrappedValue))/10")
                    .font(.caption.monospacedDigit().weight(.black))
                    .foregroundStyle(accent)
            }
            Slider(value: value, in: 0...10, step: 1)
                .tint(accent)
                .accessibilityValue("\(Int(value.wrappedValue)) out of 10")
        }
    }

    private func save() {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else {
            validationMessage = "Give the facility a name before saving the report."
            return
        }

        validationMessage = nil
        onSave(
            String(cleanName.prefix(100)),
            Int(cleanliness),
            Int(privacy),
            Int(supplies),
            Int(queue),
            changingTableObserved,
            note.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        dismiss()
    }
}

#if canImport(PreviewsMacros)
#Preview { BathroomMapView() }
#endif
