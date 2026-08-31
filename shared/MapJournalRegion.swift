import Foundation
import MapKit

/// Persists the last map viewport for field-journal apps so cold starts
/// reopen where the user left off instead of a hard-coded city.
public enum MapJournalRegionStore {
    public struct StoredRegion: Codable, Sendable {
        public let latitude: Double
        public let longitude: Double
        public let latitudeDelta: Double
        public let longitudeDelta: Double

        public init(_ region: MKCoordinateRegion) {
            latitude = region.center.latitude
            longitude = region.center.longitude
            latitudeDelta = region.span.latitudeDelta
            longitudeDelta = region.span.longitudeDelta
        }

        public var coordinateRegion: MKCoordinateRegion {
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            )
        }
    }

    /// Wide neutral view — user pans to their city; not tied to one metro.
    public static let neutralFallback = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 60, longitudeDelta: 60)
    )

    public static func load(storageKey: String, fallback: MKCoordinateRegion = neutralFallback) -> MKCoordinateRegion {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let stored = try? JSONDecoder().decode(StoredRegion.self, from: data)
        else {
            return fallback
        }
        return stored.coordinateRegion
    }

    public static func save(_ region: MKCoordinateRegion, storageKey: String) {
        guard let data = try? JSONEncoder().encode(StoredRegion(region)) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
