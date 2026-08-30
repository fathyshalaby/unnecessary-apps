import Foundation
import UserNotifications

public enum DumbNotificationAuthorization: Sendable {
    case available
    case notDetermined
    case denied
}

public enum DumbNotificationScheduleResult: Sendable {
    case scheduled(Date)
    case denied
    case failed
}

/// Small local-only notification foundation shared by apps that have a real,
/// user-created reminder. It intentionally has no remote-push or analytics path.
public enum DumbLocalNotifications {
    public static func authorization() async -> DumbNotificationAuthorization {
        let status = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
        switch status {
        case .authorized, .provisional, .ephemeral:
            return .available
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        @unknown default:
            return .denied
        }
    }

    public static func scheduleOneShot(
        identifier: String,
        title: String,
        body: String,
        proposedDate: Date,
        userInfo: [AnyHashable: Any] = [:]
    ) async -> DumbNotificationScheduleResult {
        let center = UNUserNotificationCenter.current()
        let status = await center.notificationSettings().authorizationStatus
        let allowed: Bool

        switch status {
        case .authorized, .provisional, .ephemeral:
            allowed = true
        case .notDetermined:
            allowed = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        case .denied:
            allowed = false
        @unknown default:
            allowed = false
        }

        guard allowed else { return .denied }

        let fireDate = quietHoursAdjusted(proposedDate)
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        if !userInfo.isEmpty {
            content.userInfo = userInfo
        }

        let components = Calendar.autoupdatingCurrent.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: fireDate
        )
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        )

        do {
            try await center.add(request)
            return .scheduled(fireDate)
        } catch {
            return .failed
        }
    }

    /// Schedules one quiet-hours-aware reminder at the same local time each
    /// day. Recurring reminders are intentionally explicit and use a stable
    /// identifier so an edit replaces the previous schedule.
    public static func scheduleDaily(
        identifier: String,
        title: String,
        body: String,
        proposedTime: Date
    ) async -> DumbNotificationScheduleResult {
        let center = UNUserNotificationCenter.current()
        let status = await center.notificationSettings().authorizationStatus
        let allowed: Bool

        switch status {
        case .authorized, .provisional, .ephemeral:
            allowed = true
        case .notDetermined:
            allowed = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        case .denied:
            allowed = false
        @unknown default:
            allowed = false
        }

        guard allowed else { return .denied }

        let calendar = Calendar.autoupdatingCurrent
        let proposedHour = calendar.component(.hour, from: proposedTime)
        let proposedMinute = calendar.component(.minute, from: proposedTime)
        let hour: Int
        let minute: Int

        if proposedHour < 9 {
            hour = 9
            minute = 0
        } else if proposedHour > 20 || (proposedHour == 20 && proposedMinute > 30) {
            hour = 9
            minute = 0
        } else {
            hour = proposedHour
            minute = proposedMinute
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let components = DateComponents(hour: hour, minute: minute)
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        )

        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.removeDeliveredNotifications(withIdentifiers: [identifier])

        do {
            try await center.add(request)
            let nextDate = calendar.nextDate(
                after: Date(),
                matching: components,
                matchingPolicy: .nextTimePreservingSmallerComponents
            ) ?? Date()
            return .scheduled(nextDate)
        } catch {
            return .failed
        }
    }

    public static func cancel(identifier: String) {
        cancel(identifiers: [identifier])
    }

    public static func cancel(identifiers: [String]) {
        guard !identifiers.isEmpty else { return }
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    public static func quietHoursAdjusted(_ proposedDate: Date) -> Date {
        let calendar = Calendar.autoupdatingCurrent
        let hour = calendar.component(.hour, from: proposedDate)
        let minute = calendar.component(.minute, from: proposedDate)

        if hour < 9 {
            return calendar.date(bySettingHour: 9, minute: 0, second: 0, of: proposedDate) ?? proposedDate
        }
        if hour > 20 || (hour == 20 && minute > 30) {
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: proposedDate) ?? proposedDate
            return calendar.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrow) ?? tomorrow
        }
        return proposedDate
    }
}
