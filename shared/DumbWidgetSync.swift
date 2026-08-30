import Foundation

/// App Group snapshots for Home Screen widgets and Share extensions.
public enum DumbWidgetSync {
    public static let appGroupID = "group.corp.unecessary.shared"

    public enum App: String {
        case doNotTextThem = "app03"
        case realEmail = "app20"
        case overthinking = "app28"
        case apology = "app30"
        case stepDebt = "app36"
        case hydration = "app43"
        case queue = "app33"
        case walkingMeeting = "app42"
        case heartRate = "app38"
    }

    private static var store: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    public static func publish(_ app: App, values: [String: String]) {
        guard let store else { return }
        for (key, value) in values {
            store.set(value, forKey: "\(app.rawValue).\(key)")
        }
        store.set(Date().timeIntervalSince1970, forKey: "\(app.rawValue).updatedAt")
    }

    public static func string(_ app: App, key: String, default defaultValue: String = "") -> String {
        store?.string(forKey: "\(app.rawValue).\(key)") ?? defaultValue
    }

    public static func double(_ app: App, key: String, default defaultValue: Double = 0) -> Double {
        store?.double(forKey: "\(app.rawValue).\(key)") ?? defaultValue
    }

    public static func int(_ app: App, key: String, default defaultValue: Int = 0) -> Int {
        Int(store?.double(forKey: "\(app.rawValue).\(key)") ?? Double(defaultValue))
    }

    public static func updatedAt(_ app: App) -> Date {
        Date(timeIntervalSince1970: store?.double(forKey: "\(app.rawValue).updatedAt") ?? 0)
    }
}

public enum DumbSharedPayload {
    public static func store(_ text: String, for app: DumbWidgetSync.App) {
        DumbWidgetSync.publish(app, values: ["sharePayload": text])
    }

    public static func consume(for app: DumbWidgetSync.App) -> String? {
        let text = DumbWidgetSync.string(app, key: "sharePayload")
        guard !text.isEmpty else { return nil }
        DumbWidgetSync.publish(app, values: ["sharePayload": ""])
        return text
    }
}
