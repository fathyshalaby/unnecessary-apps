@preconcurrency import CoreLocation
import MapKit
import Observation
import SwiftUI
import DumbKit

@main
struct QuietCafeApp: App {
    var body: some Scene {
        WindowGroup { QuietCafeView().dumbNativeEntry(scheme: "app23quietcafe") { _, _ in } }
    }
}

private struct CafeCoordinate: Codable, Hashable {
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

private enum VisitPeriod: String, Codable, CaseIterable, Identifiable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"

    var id: String { rawValue }
}

private struct CafeReview: Codable, Identifiable, Hashable {
    let id: UUID
    let createdAt: Date
    let coordinate: CafeCoordinate
    var name: String
    var quietness: Int
    var seating: Int
    var outlets: Int
    var soloFriendly: Bool
    var visitPeriod: VisitPeriod
    var note: String

    var index: Int {
        let soloScore = soloFriendly ? 10 : 4
        return Int((Double(quietness + seating + outlets + soloScore) / 4).rounded())
    }

    var shareText: String {
        var lines = [
            "\(name) — \(index)/10",
            "Quiet \(quietness) · Seat \(seating) · Plugs \(outlets) · \(visitPeriod.rawValue) visit",
            soloFriendly ? "Solo table approved" : "Bring social camouflage"
        ]
        if !note.isEmpty {
            lines.append(note)
        }
        return lines.joined(separator: "\n")
    }
}

private struct CafePlace: Identifiable, Hashable {
    let id: String
    let name: String
    let address: String
    let coordinate: CafeCoordinate

    init(name: String, address: String, coordinate: CLLocationCoordinate2D) {
        self.name = name
        self.address = address
        self.coordinate = CafeCoordinate(coordinate)
        id = "\(name)|\(coordinate.latitude)|\(coordinate.longitude)"
    }
}

private struct CafeDraft: Identifiable {
    let id = UUID()
    let suggestedName: String
    let coordinate: CafeCoordinate
    let existingReview: CafeReview?

    init(suggestedName: String, coordinate: CafeCoordinate, existingReview: CafeReview? = nil) {
        self.suggestedName = suggestedName
        self.coordinate = coordinate
        self.existingReview = existingReview
    }
}

@MainActor
@Observable
private final class CafeReviewStore {
    private static let storageKey = "quietCafe.reviews.v2"
    private static let maximumReviews = 100

    @ObservationIgnored private let defaults: UserDefaults
    private(set) var reviews: [CafeReview]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        guard
            let data = defaults.data(forKey: Self.storageKey),
            let decoded = try? JSONDecoder().decode([CafeReview].self, from: data)
        else {
            reviews = []
            return
        }
        reviews = Array(decoded.prefix(Self.maximumReviews))
    }

    func add(
        coordinate: CafeCoordinate,
        name: String,
        quietness: Int,
        seating: Int,
        outlets: Int,
        soloFriendly: Bool,
        visitPeriod: VisitPeriod,
        note: String
    ) {
        let review = CafeReview(
            id: UUID(),
            createdAt: .now,
            coordinate: coordinate,
            name: name,
            quietness: quietness,
            seating: seating,
            outlets: outlets,
            soloFriendly: soloFriendly,
            visitPeriod: visitPeriod,
            note: note
        )
        reviews.insert(review, at: 0)
        reviews = Array(reviews.prefix(Self.maximumReviews))
        persist()
    }

    func update(
        id: UUID,
        coordinate: CafeCoordinate,
        name: String,
        quietness: Int,
        seating: Int,
        outlets: Int,
        soloFriendly: Bool,
        visitPeriod: VisitPeriod,
        note: String
    ) {
        guard let index = reviews.firstIndex(where: { $0.id == id }) else { return }
        let existing = reviews[index]
        reviews[index] = CafeReview(
            id: id,
            createdAt: existing.createdAt,
            coordinate: coordinate,
            name: name,
            quietness: quietness,
            seating: seating,
            outlets: outlets,
            soloFriendly: soloFriendly,
            visitPeriod: visitPeriod,
            note: note
        )
        persist()
    }

    func remove(id: UUID) {
        reviews.removeAll { $0.id == id }
        persist()
    }

    func removeAll() {
        reviews.removeAll()
        defaults.removeObject(forKey: Self.storageKey)
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(reviews) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }
}

@MainActor
@Observable
private final class CafeSearchService {
    @ObservationIgnored private var activeSearch: MKLocalSearch?

    private(set) var results: [CafePlace] = []
    private(set) var isSearching = false
    private(set) var statusMessage = "Move the map, then find real cafés in that area."

    func search(region: MKCoordinateRegion) async {
        activeSearch?.cancel()
        isSearching = true
        statusMessage = "Asking Apple Maps where the coffee is…"

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "café"
        request.region = region
        request.resultTypes = .pointOfInterest
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.cafe])

        let search = MKLocalSearch(request: request)
        activeSearch = search

        do {
            let response = try await search.start()
            guard activeSearch === search else { return }
            results = response.mapItems.prefix(12).compactMap { item in
                guard let name = item.name, !name.isEmpty else { return nil }
                return CafePlace(
                    name: name,
                    address: item.placemark.title ?? "Address unavailable",
                    coordinate: item.placemark.coordinate
                )
            }
            statusMessage = results.isEmpty
                ? "Apple Maps found no cafés here. Pan somewhere else or drop a pin."
                : "Found \(results.count) nearby café\(results.count == 1 ? "" : "s"). The whisper audit may begin."
        } catch is CancellationError {
            return
        } catch {
            guard activeSearch === search else { return }
            results = []
            statusMessage = "Café search is taking a break. Drop a pin instead."
        }

        if activeSearch === search {
            activeSearch = nil
            isSearching = false
        }
    }
}

@MainActor
@Observable
private final class CafeLocationService: NSObject, @preconcurrency CLLocationManagerDelegate {
    @ObservationIgnored private let manager = CLLocationManager()
    @ObservationIgnored private var shouldRequestLocationAfterAuthorization = false

    private(set) var lastCoordinate: CafeCoordinate?
    private(set) var statusMessage = "Search nearby or move the pin to a café you visited."
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
            statusMessage = "Looking for your current coffee radius…"
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
        lastCoordinate = CafeCoordinate(location.coordinate)
        statusMessage = "Map centered. Move the pin if the whisper coordinates are slightly off."
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isWorking = false
        statusMessage = "Could not get a position. Pan the map to continue."
    }
}

struct QuietCafeView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private static let regionStorageKey = "quietCafe.region"
    private static let initialRegion = MapJournalRegionStore.load(storageKey: regionStorageKey)

    @State private var store = CafeReviewStore()
    @State private var searchService = CafeSearchService()
    @State private var locationService = CafeLocationService()
    @State private var cameraPosition: MapCameraPosition = .region(initialRegion)
    @State private var visibleRegion = initialRegion
    @State private var mapCenter = CafeCoordinate(initialRegion.center)
    @State private var presentedDraft: CafeDraft?
    @State private var showClearConfirmation = false

    private let accent = CorpPalette.parkGreen

    var body: some View {
        ZStack {
            CorpPalette.canvas.ignoresSafeArea()
            VStack(spacing: 0) {
                brandHeader
                DumbBoundaryChip(
                    storageKey: "quietCafe.boundaryDismissed",
                    message: "Your visit notes only — not live noise levels or business hours.",
                    accent: accent,
                    systemImage: "cup.and.saucer.fill"
                )
                .padding(.horizontal, DumbSpacing.md)
                .padding(.bottom, DumbSpacing.sm)
                mapCard
                cafeDesk
            }
        }
        .tint(accent)
        .environment(\.dumbExperienceStyle, .map)
        .sheet(item: $presentedDraft) { draft in
            CafeEditorSheet(draft: draft) { name, quietness, seating, outlets, soloFriendly, visitPeriod, note in
                if let existing = draft.existingReview {
                    store.update(
                        id: existing.id,
                        coordinate: draft.coordinate,
                        name: name,
                        quietness: quietness,
                        seating: seating,
                        outlets: outlets,
                        soloFriendly: soloFriendly,
                        visitPeriod: visitPeriod,
                        note: note
                    )
                } else {
                    store.add(
                        coordinate: draft.coordinate,
                        name: name,
                        quietness: quietness,
                        seating: seating,
                        outlets: outlets,
                        soloFriendly: soloFriendly,
                        visitPeriod: visitPeriod,
                        note: note
                    )
                }
            }
        }
        .confirmationDialog(
            "Clear every café review?",
            isPresented: $showClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("Clear all café reviews", role: .destructive) {
                store.removeAll()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This clears every café review. It cannot be undone.")
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
                Text("SOLO COFFEE INTELLIGENCE")
                    .font(.caption2.weight(.black))
                    .tracking(1.2)
                    .foregroundStyle(accent)
                Text("Quiet Café Index")
                    .font(.system(.title3, design: .rounded).weight(.black))
                    .foregroundStyle(CorpPalette.ink)
                    .lineLimit(1)
                    .accessibilityAddTraits(.isHeader)
                Text("Private visit notes for cafés you've actually visited.")
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
                Marker(place.name, systemImage: "cup.and.saucer.fill", coordinate: place.coordinate.clLocationCoordinate)
                    .tint(CorpPalette.coral)
            }
            ForEach(store.reviews) { review in
                Marker(review.name, systemImage: "ear.fill", coordinate: review.coordinate.clLocationCoordinate)
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
            mapCenter = CafeCoordinate(context.region.center)
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
            .accessibilityHint("Requests location only to center the café map near you.")
            .accessibilityIdentifier("useCafeLocationButton")
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
                            Label("Find cafés", systemImage: "magnifyingglass")
                        }
                    }
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(CorpPalette.actionInk)
                    .frame(maxWidth: .infinity, minHeight: DumbMetrics.minimumTapTarget)
                    .background(accent, in: Capsule())
                }
                .disabled(searchService.isSearching)
                .buttonStyle(DumbPressStyle())
                .accessibilityIdentifier("findCafesButton")

                Button {
                    presentedDraft = CafeDraft(suggestedName: "", coordinate: mapCenter)
                } label: {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.headline.weight(.black))
                        .foregroundStyle(accent)
                        .frame(width: DumbMetrics.minimumTapTarget, height: DumbMetrics.minimumTapTarget)
                        .background(CorpPalette.surface.opacity(0.94), in: Circle())
                }
                .buttonStyle(DumbPressStyle())
                .accessibilityLabel("Review the place under the center marker")
                .accessibilityIdentifier("reviewCafeMapCenterButton")
            }
            .padding(.horizontal, DumbSpacing.sm)
            .padding(.bottom, DumbSpacing.sm)
        }
        .frame(height: 360)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(CorpPalette.ink.opacity(0.08), lineWidth: 1))
        .padding(.horizontal, DumbSpacing.sm)
    }

    private var cafeDesk: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: DumbSpacing.sm) {
                statusStrip

                if !searchService.results.isEmpty {
                    searchResults
                }

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.reviews.isEmpty ? "No ratings yet" : "\(store.reviews.count) café rating\(store.reviews.count == 1 ? "" : "s") on file")
                            .font(.headline.weight(.black))
                            .foregroundStyle(CorpPalette.ink)
                        Text("Filed for your next quiet escape.")
                            .font(.caption)
                            .foregroundStyle(CorpPalette.mutedInk)
                    }
                    Spacer()
                    if !store.reviews.isEmpty {
                        Button("Clear all", role: .destructive) {
                            showClearConfirmation = true
                        }
                        .font(.caption.weight(.bold))
                        .accessibilityIdentifier("clearCafeReviewsButton")
                    }
                }

                if store.reviews.isEmpty {
                    emptyState
                } else {
                    ForEach(store.reviews) { review in
                        CafeReviewCard(review: review, accent: accent) {
                            visibleRegion = MKCoordinateRegion(
                                center: review.coordinate.clLocationCoordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.006)
                            )
                            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) {
                                cameraPosition = .region(visibleRegion)
                            }
                        } onEdit: {
                            presentedDraft = CafeDraft(
                                suggestedName: review.name,
                                coordinate: review.coordinate,
                                existingReview: review
                            )
                        } onDelete: {
                            store.remove(id: review.id)
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
            Label(searchService.statusMessage, systemImage: "cup.and.saucer.fill")
            Label(locationService.statusMessage, systemImage: "location.circle.fill")
        }
        .font(.caption)
        .foregroundStyle(CorpPalette.mutedInk)
        .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, DumbSpacing.micro)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("quietCafeStatus")
    }

    private var searchResults: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("APPLE MAPS RESULTS")
                .font(.caption2.weight(.black))
                .tracking(1.1)
                .foregroundStyle(accent)
            ScrollView(.horizontal) {
                LazyHStack(spacing: 10) {
                    ForEach(searchService.results) { place in
                        Button {
                            presentedDraft = CafeDraft(suggestedName: place.name, coordinate: place.coordinate)
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
                                Label("Rate this café", systemImage: "square.and.pencil")
                                    .font(.caption2.weight(.black))
                                    .foregroundStyle(accent)
                            }
                            .frame(width: 188, alignment: .leading)
                            .padding(DumbSpacing.sm)
                            .background(CorpPalette.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(CorpPalette.ink.opacity(0.06), lineWidth: 1))
                        }
                        .buttonStyle(DumbPressStyle())
                        .accessibilityIdentifier("cafeSearchResult")
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private var emptyState: some View {
        DumbEmptyInvite(
            title: "The quiet committee has no evidence",
            message: "Find a real café or use the map pin, then rate what it felt like when you visited.",
            systemImage: "ear.badge.waveform",
            accent: accent
        )
        .accessibilityIdentifier("emptyCafeLedger")
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

private struct CafeReviewCard: View {
    let review: CafeReview
    let accent: Color
    let onShow: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.name)
                        .font(.headline.weight(.black))
                        .foregroundStyle(CorpPalette.ink)
                    Text("\(review.visitPeriod.rawValue) visit · \(review.createdAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(CorpPalette.mutedInk)
                }
                Spacer()
                Text("\(review.index)/10")
                    .font(.system(.title3, design: .rounded).weight(.black))
                    .foregroundStyle(accent)
            }

            HStack(spacing: 7) {
                scorePill("Quiet \(review.quietness)", icon: "ear.fill")
                scorePill("Seat \(review.seating)", icon: "chair.lounge.fill")
                scorePill("Plugs \(review.outlets)", icon: "powerplug.fill")
            }

            if !review.note.isEmpty {
                Text(review.note)
                    .font(.subheadline)
                    .foregroundStyle(CorpPalette.mutedInk)
                    .lineLimit(3)
            }

            HStack {
                Label(
                    review.soloFriendly ? "Solo table approved" : "Bring social camouflage",
                    systemImage: review.soloFriendly ? "person.fill.checkmark" : "person.fill.questionmark"
                )
                .font(.caption.weight(.bold))
                .foregroundStyle(CorpPalette.mutedInk)
                Spacer()
                Button("Show", action: onShow)
                    .font(.caption.weight(.black))
                ShareLink(item: review.shareText, subject: Text("Café field report"), message: Text(review.shareText)) {
                    Text("Share")
                        .font(.caption.weight(.black))
                }
                .accessibilityIdentifier("shareCafeReviewButton")
                Button("Edit", action: onEdit)
                    .font(.caption.weight(.black))
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                }
                .accessibilityLabel("Delete \(review.name)")
            }
        }
        .padding(DumbSpacing.md)
        .background(CorpPalette.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(CorpPalette.ink.opacity(0.06), lineWidth: 1))
        .accessibilityIdentifier("cafeReviewCard")
    }

    private func scorePill(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.caption2.weight(.black))
            .foregroundStyle(CorpPalette.ink.opacity(0.78))
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, DumbSpacing.xs)
            .padding(.vertical, DumbSpacing.micro + 2)
            .background(accent.opacity(0.12), in: Capsule())
    }
}

private struct CafeEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    let draft: CafeDraft
    let onSave: (String, Int, Int, Int, Bool, VisitPeriod, String) -> Void

    @State private var name: String
    @State private var quietness = 7.0
    @State private var seating = 7.0
    @State private var outlets = 5.0
    @State private var soloFriendly = true
    @State private var visitPeriod = VisitPeriod.afternoon
    @State private var note = ""
    @State private var validationMessage: String?

    private let accent = CorpPalette.parkGreen

    init(
        draft: CafeDraft,
        onSave: @escaping (String, Int, Int, Int, Bool, VisitPeriod, String) -> Void
    ) {
        self.draft = draft
        self.onSave = onSave
        let review = draft.existingReview
        _name = State(initialValue: review?.name ?? draft.suggestedName)
        _quietness = State(initialValue: Double(review?.quietness ?? 7))
        _seating = State(initialValue: Double(review?.seating ?? 7))
        _outlets = State(initialValue: Double(review?.outlets ?? 5))
        _soloFriendly = State(initialValue: review?.soloFriendly ?? true)
        _visitPeriod = State(initialValue: review?.visitPeriod ?? .afternoon)
        _note = State(initialValue: review?.note ?? "")
    }

    private var isEditing: Bool { draft.existingReview != nil }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    sourceTicket

                    DumbCard(accent: accent) {
                        VStack(alignment: .leading, spacing: 14) {
                            DumbField("Café name", maxLength: 100, text: $name)
                                .accessibilityIdentifier("cafeNameField")

                            VStack(alignment: .leading, spacing: 6) {
                                Text("WHEN DID YOU VISIT?")
                                    .font(.caption2.weight(.black))
                                    .tracking(1.0)
                                    .foregroundStyle(CorpPalette.mutedInk)
                                Picker("Visit period", selection: $visitPeriod) {
                                    ForEach(VisitPeriod.allCases) { period in
                                        Text(period.rawValue).tag(period)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .accessibilityIdentifier("cafeVisitPeriodPicker")
                            }

                            ratingSlider("Quietness", value: $quietness, icon: "ear.fill")
                            ratingSlider("Seating", value: $seating, icon: "chair.lounge.fill")
                            ratingSlider("Outlet odds", value: $outlets, icon: "powerplug.fill")

                            Toggle("Comfortable sitting alone", isOn: $soloFriendly)
                                .font(.subheadline.weight(.bold))
                                .tint(accent)
                                .accessibilityIdentifier("cafeSoloFriendlyToggle")
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
                                .accessibilityLabel("Café note")
                                .accessibilityIdentifier("cafeNoteField")
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
                            .accessibilityIdentifier("cafeValidationMessage")
                    }

                    DumbAction(
                        title: isEditing ? "Update café rating" : "Save café rating",
                        accent: accent,
                        systemImage: "tray.and.arrow.down.fill",
                        action: save
                    )
                        .accessibilityIdentifier("saveCafeReviewButton")
                }
                .padding(18)
            }
            .background(CorpPalette.canvas.ignoresSafeArea())
            .navigationTitle(isEditing ? "Edit café report" : "Café field report")
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
                Text(draft.suggestedName.isEmpty ? "YOUR MAP PIN" : "APPLE MAPS PLACE")
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
            validationMessage = "Give the café a name before filing the report."
            return
        }

        validationMessage = nil
        onSave(
            String(cleanName.prefix(100)),
            Int(quietness),
            Int(seating),
            Int(outlets),
            soloFriendly,
            visitPeriod,
            note.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        dismiss()
    }
}
