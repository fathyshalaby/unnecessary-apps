import Foundation
import SwiftUI
import UserNotifications

#if os(iOS)
import UIKit
#endif

/// Queued launch actions from Siri, Shortcuts, widgets, or URL opens.
/// Each app consumes its pending action when the root view appears.
public enum DumbPendingLaunch {
    public static let actionKey = "dumb.pendingLaunch.action"
    public static let payloadKey = "dumb.pendingLaunch.payload"

    public static func queue(action: String, payload: String = "") {
        UserDefaults.standard.set(action, forKey: actionKey)
        UserDefaults.standard.set(payload, forKey: payloadKey)
    }

    public static func peek() -> (action: String, payload: String)? {
        guard let action = UserDefaults.standard.string(forKey: actionKey), !action.isEmpty else { return nil }
        let payload = UserDefaults.standard.string(forKey: payloadKey) ?? ""
        return (action, payload)
    }

    public static func consume() -> (action: String, payload: String)? {
        guard let pending = peek() else { return nil }
        UserDefaults.standard.removeObject(forKey: actionKey)
        UserDefaults.standard.removeObject(forKey: payloadKey)
        return pending
    }
}

public enum DumbNativeRoute {
    public static let userInfoKey = "dumbRoute"

    /// Parses `app03donottextthem://start?message=hello` style links registered per target.
    public static func parse(url: URL) -> (action: String, payload: String)? {
        guard let scheme = url.scheme?.lowercased(), scheme.hasPrefix("app") else { return nil }
        let action = url.host?.lowercased() ?? url.pathComponents.dropFirst().first?.lowercased() ?? "open"
        var payload = ""
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            if let message = queryItems.first(where: { $0.name == "message" })?.value {
                payload = message
            } else if let text = queryItems.first(where: { $0.name == "text" })?.value {
                payload = text
            } else if let crime = queryItems.first(where: { $0.name == "crime" })?.value {
                payload = crime
            }
        }
        return (action, payload)
    }

    public static func url(scheme: String, action: String, query: [String: String] = [:]) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = action
        if !query.isEmpty {
            components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        return components.url
    }
}

#if os(iOS)
/// Forwards notification taps that include a `dumbRoute` payload.
public final class DumbNotificationDelegate: NSObject, UNUserNotificationCenterDelegate, @unchecked Sendable {
    public static let shared = DumbNotificationDelegate()
    public static let didReceiveResponse = Notification.Name("DumbNotificationDidReceiveResponse")

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        NotificationCenter.default.post(name: Self.didReceiveResponse, object: userInfo)
    }
}

public enum DumbNativeInstall {
    public static func activate() {
        UNUserNotificationCenter.current().delegate = DumbNotificationDelegate.shared
    }
}
#endif

/// Small in-app hint that Siri / Shortcuts / Handoff are available — feels native, not promotional.
public struct DumbNativeTip: View {
    let title: String
    let detail: String
    let systemImage: String
    let accent: Color

    public init(
        _ title: String,
        detail: String,
        systemImage: String = "sparkles.rectangle.stack.fill",
        accent: Color
    ) {
        self.title = title
        self.detail = detail
        self.systemImage = systemImage
        self.accent = accent
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title3.weight(.black))
                .foregroundStyle(accent)
                .frame(width: 36, height: 36)
                .background(accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(title.uppercased())
                    .font(.caption2.weight(.black))
                    .tracking(0.9)
                    .foregroundStyle(accent)
                Text(detail)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CorpPalette.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(DumbSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CorpPalette.surface.opacity(0.72), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

public extension View {
    /// Handles custom-scheme URLs and queued Shortcuts actions with one modifier.
    func dumbNativeEntry(
        scheme: String,
        onRoute: @escaping (_ action: String, _ payload: String) -> Void
    ) -> some View {
        modifier(DumbNativeEntryModifier(scheme: scheme, onRoute: onRoute))
    }

    /// Keeps an in-progress draft eligible for Handoff / Continuity.
    func dumbHandoffDraft(
        _ activityType: String,
        title: String,
        isActive: Bool,
        payload: [String: String],
        onContinue: @escaping ([String: String]) -> Void
    ) -> some View {
        background(HandoffContinuityObserver(activityType: activityType, onContinue: onContinue))
            .userActivity(isActive ? activityType : "") { activity in
                activity.title = title
                activity.isEligibleForHandoff = true
                activity.userInfo = payload
            }
    }
}

private struct HandoffContinuityObserver: View {
    let activityType: String
    let onContinue: ([String: String]) -> Void

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .onContinueUserActivity(activityType) { activity in
                guard let userInfo = activity.userInfo as? [String: String] else { return }
                onContinue(userInfo)
            }
    }
}

private struct DumbNativeEntryModifier: ViewModifier {
    let scheme: String
    let onRoute: (_ action: String, _ payload: String) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear {
                #if os(iOS)
                DumbNativeInstall.activate()
                #endif
                if let pending = DumbPendingLaunch.consume() {
                    onRoute(pending.action, pending.payload)
                }
            }
            .onOpenURL { url in
                guard url.scheme?.lowercased() == scheme.lowercased(),
                      let route = DumbNativeRoute.parse(url: url) else { return }
                onRoute(route.action, route.payload)
            }
            #if os(iOS)
            .onReceive(NotificationCenter.default.publisher(for: DumbNotificationDelegate.didReceiveResponse)) { notification in
                guard let userInfo = notification.object as? [AnyHashable: Any],
                      let route = userInfo[DumbNativeRoute.userInfoKey] as? String else { return }
                let parts = route.split(separator: ":", maxSplits: 1).map(String.init)
                let action = parts.first ?? "open"
                let payload = parts.count > 1 ? parts[1] : ""
                onRoute(action, payload)
            }
            #endif
    }
}
