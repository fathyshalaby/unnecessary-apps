import SwiftUI
import Foundation

#if os(iOS)
import UIKit
#endif

public enum DumbPersonality: Sendable {
    case office
    case optimistic
    case dramatic
    case chaotic
}

public enum DumbReactionStyle: Sendable {
    case bounce
    case shake
    case stamp
}

/// Visual and interaction grammar for an individual Unnecessary App.
/// The apps share implementation primitives, but each one can feel like a
/// different tiny product instead of a recolored template.
public enum DumbExperienceStyle: Sendable, Equatable {
    case dossier
    case receipt
    case courtroom
    case camera
    case journal
    case gallery
    case game
    case timer
    case meter
    case route
    case wellness
    case oracle
    case workbench
    case map

    public var departmentLabel: String {
        switch self {
        case .dossier: return "EVIDENCE DESK"
        case .receipt: return "RECEIPT SERVICES"
        case .courtroom: return "THE PEOPLE V. YOU"
        case .camera: return "FIELD CAMERA UNIT"
        case .journal: return "PRIVATE FIELD NOTES"
        case .gallery: return "SMALL THINGS ARCHIVE"
        case .game: return "RECREATIONAL OVERSIGHT"
        case .timer: return "TIME MANAGEMENT THEATRE"
        case .meter: return "UNLICENSED MEASUREMENT"
        case .route: return "OUTSIDE COORDINATION"
        case .wellness: return "GENTLE BODY ADMIN"
        case .oracle: return "QUESTIONABLE WISDOM"
        case .workbench: return "PRACTICAL NONSENSE"
        case .map: return "CIVIC FIELD GUIDE"
        }
    }

    public var cardRadius: CGFloat {
        switch self {
        case .receipt: return 7
        case .courtroom: return 14
        case .journal: return 12
        case .game: return 30
        case .timer: return 20
        case .meter: return 18
        case .gallery: return 18
        case .camera, .map: return 24
        case .route: return 16
        case .wellness: return 24
        case .oracle: return 22
        case .dossier, .workbench: return 24
        }
    }

    public var actionRadius: CGFloat {
        switch self {
        case .receipt: return 8
        case .courtroom: return 12
        case .game: return 30
        case .timer, .wellness: return 24
        case .camera, .gallery: return 18
        case .meter: return 16
        case .route: return 14
        case .oracle: return 20
        case .journal: return 10
        case .dossier, .workbench, .map: return 21
        }
    }

    public var cardPadding: CGFloat {
        switch self {
        case .receipt: return 16
        case .courtroom, .journal: return 17
        case .game: return 20
        case .timer, .meter: return 18
        case .camera, .gallery, .wellness: return 18
        case .route, .oracle: return 17
        case .dossier, .workbench, .map: return 18
        }
    }

    public var cardShadowRadius: CGFloat {
        switch self {
        case .receipt, .courtroom, .journal: return 2
        case .game: return 16
        case .timer, .meter, .route: return 8
        case .camera, .gallery, .wellness, .oracle: return 12
        case .dossier, .workbench, .map: return 12
        }
    }

    public var cardShadowY: CGFloat {
        switch self {
        case .receipt, .courtroom, .journal: return 2
        case .game: return 8
        case .timer, .meter, .route: return 5
        case .camera, .gallery, .wellness, .oracle: return 6
        case .dossier, .workbench, .map: return 6
        }
    }

    public var resultLabel: String {
        switch self {
        case .receipt: return "ITEMIZED RESULT"
        case .courtroom: return "COURT RULING"
        case .camera: return "FIELD IDENTIFICATION"
        case .journal, .gallery: return "ARCHIVE ENTRY"
        case .game: return "ROUND RESULT"
        case .timer: return "TIME REPORT"
        case .meter: return "MEASUREMENT RESULT"
        case .route: return "DIRECTIONS FROM THE BUREAU"
        case .wellness: return "GENTLE CHECK-IN"
        case .oracle: return "THE ORACLE SAYS"
        case .workbench: return "WORKSHOP RESULT"
        case .map: return "FIELD REPORT"
        case .dossier: return "OFFICIAL RESULT"
        }
    }

    public static func inferred(from eyebrow: String, title: String) -> Self {
        let clue = "\(eyebrow) \(title)".lowercased()

        if clue.contains("map") || clue.contains("café") || clue.contains("cafe") || clue.contains("bench") {
            return .map
        }
        if clue.contains("pigeon") || clue.contains("seagull") || clue.contains("dog name") {
            return .camera
        }
        if clue.contains("receipt") || clue.contains("battery") || clue.contains("damage") {
            return .receipt
        }
        if clue.contains("court") || clue.contains("tribunal") || clue.contains("sock") || clue.contains("door was push") {
            return .courtroom
        }
        if clue.contains("museum") {
            return .gallery
        }
        if clue.contains("gratitude") || clue.contains("what was i doing") || clue.contains("evidence board") {
            return .journal
        }
        if clue.contains("bingo") || clue.contains("roulette") || clue.contains("queue") {
            return .game
        }
        if clue.contains("last slice") {
            return .game
        }
        if clue.contains("timer") || clue.contains("waiting room") || clue.contains("episode") || clue.contains("sleep alibi") || clue.contains("do not text") {
            return .timer
        }
        if clue.contains("vibe") || clue.contains("early") || clue.contains("step debt") || clue.contains("workout") {
            return .meter
        }
        if clue.contains("gps") || clue.contains("walking meeting") || clue.contains("neighbor noise") {
            return .route
        }
        if clue.contains("medieval") || clue.contains("peasant") || clue.contains("horoscope") || clue.contains("oracle") {
            return .oracle
        }
        if clue.contains("health") || clue.contains("heart rate") || clue.contains("hydration") || clue.contains("recovery") || clue.contains("rest day") || clue.contains("lab") {
            return .wellness
        }
        if clue.contains("chair") || clue.contains("laundry") || clue.contains("fridge") || clue.contains("microwave") || clue.contains("plant") || clue.contains("wear it") || clue.contains("weather") {
            return .workbench
        }
        if clue.contains("apology") || clue.contains("email") {
            return .dossier
        }
        return .dossier
    }
}

private struct DumbExperienceStyleKey: EnvironmentKey {
    static let defaultValue = DumbExperienceStyle.dossier
}

public extension EnvironmentValues {
    var dumbExperienceStyle: DumbExperienceStyle {
        get { self[DumbExperienceStyleKey.self] }
        set { self[DumbExperienceStyleKey.self] = newValue }
    }
}

public enum DumbMotion {
    public static let quick = Animation.spring(response: 0.22, dampingFraction: 0.78)
    public static let playful = Animation.spring(response: 0.38, dampingFraction: 0.64)
    public static let settle = Animation.spring(response: 0.46, dampingFraction: 0.84)
}

public enum DumbSpacing {
    public static let micro: CGFloat = 4
    public static let xs: CGFloat = 8
    public static let sm: CGFloat = 12
    public static let md: CGFloat = 16
    public static let lg: CGFloat = 24
    public static let xl: CGFloat = 32
    public static let xxl: CGFloat = 48
}

public enum DumbMetrics {
    public static let minimumTapTarget: CGFloat = 44
}

/// Scrollable screen wrapper without the DumbShell hero template.
/// Use for app-specific layouts; keep shared controls via DumbField, DumbAction, etc.
public struct AppCanvas<Content: View, BottomBar: View>: View {
    let accent: Color
    let experience: DumbExperienceStyle?
    @ViewBuilder let content: Content
    @ViewBuilder let bottomBar: BottomBar
    private let showsBottomBar: Bool

    public init(
        accent: Color,
        experience: DumbExperienceStyle? = nil,
        @ViewBuilder content: () -> Content
    ) where BottomBar == EmptyView {
        self.accent = accent
        self.experience = experience
        self.content = content()
        self.bottomBar = EmptyView()
        self.showsBottomBar = false
    }

    public init(
        accent: Color,
        experience: DumbExperienceStyle? = nil,
        @ViewBuilder content: () -> Content,
        @ViewBuilder bottomBar: () -> BottomBar
    ) {
        self.accent = accent
        self.experience = experience
        self.content = content()
        self.bottomBar = bottomBar()
        self.showsBottomBar = true
    }

    private var resolvedExperience: DumbExperienceStyle {
        experience ?? .dossier
    }

    public var body: some View {
        ScrollView {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DumbSpacing.md)
                .padding(.top, DumbSpacing.sm)
                .padding(.bottom, showsBottomBar ? DumbSpacing.xxl : DumbSpacing.xl)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .background {
            CorpPalette.canvas.ignoresSafeArea()
            LinearGradient(
                colors: [accent.opacity(0.10), CorpPalette.canvas.opacity(0.4), CorpPalette.canvas],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
        }
        .tint(accent)
        .environment(\.dumbExperienceStyle, resolvedExperience)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if showsBottomBar {
                VStack(spacing: DumbSpacing.sm) {
                    bottomBar
                }
                .padding(.horizontal, DumbSpacing.md)
                .padding(.top, DumbSpacing.sm)
                .padding(.bottom, DumbSpacing.sm)
                .background {
                    CorpPalette.canvas.opacity(0.96)
                    Rectangle()
                        .fill(accent.opacity(0.06))
                        .frame(height: 1)
                        .frame(maxHeight: .infinity, alignment: .top)
                }
            }
        }
    }
}

/// Compact title row for custom layouts — map apps, games, tools.
public struct AppHeader: View {
    let eyebrow: String
    let title: String
    let subtitle: String?
    let accent: Color
    let showsMascot: Bool

    public init(
        eyebrow: String,
        title: String,
        subtitle: String? = nil,
        accent: Color,
        showsMascot: Bool = true
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
        self.accent = accent
        self.showsMascot = showsMascot
    }

    public var body: some View {
        HStack(alignment: .center, spacing: DumbSpacing.sm) {
            VStack(alignment: .leading, spacing: 2) {
                Text(eyebrow)
                    .font(.caption2.weight(.black))
                    .tracking(1.2)
                    .foregroundStyle(accent)
                Text(title)
                    .font(.system(.title3, design: .rounded).weight(.black))
                    .foregroundStyle(CorpPalette.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .accessibilityAddTraits(.isHeader)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(CorpPalette.mutedInk)
                        .lineLimit(2)
                }
            }
            Spacer(minLength: DumbSpacing.xs)
            if showsMascot {
                Image("AppMascot", bundle: .main)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .padding(5)
                    .background(accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .stroke(accent.opacity(0.20), lineWidth: 1)
                    )
                    .accessibilityHidden(true)
            }
        }
        .padding(.bottom, DumbSpacing.sm)
    }
}

private enum DumbReactionPhase {
    case rest
    case anticipate
    case payoff

    static let sequence: [DumbReactionPhase] = [.rest, .anticipate, .payoff, .rest]
}

public struct DumbShell<Content: View, BottomBar: View>: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    let accent: Color
    let personality: DumbPersonality?
    let experience: DumbExperienceStyle?
    @ViewBuilder let content: Content
    @ViewBuilder let bottomBar: BottomBar
    private let showsBottomBar: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false
    @State private var mascotHasLanded = false

    public init(
        eyebrow: String,
        title: String,
        subtitle: String,
        accent: Color,
        personality: DumbPersonality? = nil,
        experience: DumbExperienceStyle? = nil,
        @ViewBuilder content: () -> Content
    ) where BottomBar == EmptyView {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
        self.accent = accent
        self.personality = personality
        self.experience = experience
        self.content = content()
        self.bottomBar = EmptyView()
        self.showsBottomBar = false
    }

    public init(
        eyebrow: String,
        title: String,
        subtitle: String,
        accent: Color,
        personality: DumbPersonality? = nil,
        experience: DumbExperienceStyle? = nil,
        @ViewBuilder content: () -> Content,
        @ViewBuilder bottomBar: () -> BottomBar
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
        self.accent = accent
        self.personality = personality
        self.experience = experience
        self.content = content()
        self.bottomBar = bottomBar()
        self.showsBottomBar = true
    }

    private var resolvedExperience: DumbExperienceStyle {
        experience ?? DumbExperienceStyle.inferred(from: eyebrow, title: title)
    }

    public var body: some View {
        ZStack {
            CorpPalette.canvas
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: DumbSpacing.lg) {
                    hero
                        .opacity(appeared ? 1 : 0)
                        .offset(y: reduceMotion || appeared ? 0 : 10)
                    content
                        .opacity(appeared ? 1 : 0)
                        .offset(y: reduceMotion || appeared ? 0 : 14)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DumbSpacing.md)
                .padding(.top, DumbSpacing.sm)
                .padding(.bottom, showsBottomBar ? DumbSpacing.xxl : DumbSpacing.xl)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if showsBottomBar {
                    VStack(spacing: 0) {
                        bottomBar
                    }
                    .padding(.horizontal, DumbSpacing.md)
                    .padding(.vertical, DumbSpacing.sm)
                    .background(CorpPalette.canvas.opacity(0.96))
                }
            }
        }
        .background(CorpPalette.canvas.ignoresSafeArea())
        .tint(accent)
        .environment(\.dumbExperienceStyle, resolvedExperience)
        .onAppear {
            guard !appeared else { return }
            if reduceMotion {
                appeared = true
                mascotHasLanded = true
            } else {
                withAnimation(.easeOut(duration: 0.34)) {
                    appeared = true
                }
                withAnimation(DumbMotion.playful.delay(0.08)) {
                    mascotHasLanded = true
                }
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(alignment: .top, spacing: DumbSpacing.sm) {
                Text(eyebrow)
                    .font(.caption.weight(.black))
                    .tracking(1.4)
                    .foregroundStyle(accent)
                Spacer(minLength: 0)
                Image("AppMascot", bundle: .main)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 54, height: 54)
                    .padding(6)
                    .background(mascotBackground)
                    .overlay(mascotOutline)
                    .rotationEffect(.degrees(resolvedPersonality == .chaotic ? -4 : Double(visualSeed - 3)))
                    .scaleEffect(mascotHasLanded ? 1 : 0.9)
                    .offset(y: mascotHasLanded ? 0 : -5)
                    .accessibilityHidden(true)
            }
            Group {
                if resolvedExperience == .courtroom || resolvedExperience == .receipt || resolvedExperience == .oracle {
                    Text(title)
                        .font(.system(.largeTitle, design: .serif).weight(.black))
                } else {
                    Text(title)
                        .font(.system(.largeTitle, design: .rounded).weight(.black))
                }
            }
            .foregroundStyle(CorpPalette.ink)
            .minimumScaleFactor(0.84)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
            Text(subtitle)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(CorpPalette.mutedInk)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 6) {
                Circle()
                    .fill(accent)
                    .frame(width: 6, height: 6)
                    .accessibilityHidden(true)
                Text(resolvedExperience.departmentLabel)
                    .font(.caption2.weight(.bold))
                    .tracking(0.7)
                    .foregroundStyle(CorpPalette.mutedInk)
            }
        }
        .padding(.bottom, DumbSpacing.xs)
    }

    @ViewBuilder private var mascotBackground: some View {
        switch resolvedExperience {
        case .receipt:
            RoundedRectangle(cornerRadius: 12, style: .continuous).fill(accent.opacity(0.16))
        case .courtroom:
            RoundedRectangle(cornerRadius: 10, style: .continuous).fill(CorpPalette.verdictGold.opacity(0.18))
        case .camera, .gallery:
            RoundedRectangle(cornerRadius: 18, style: .continuous).fill(accent.opacity(0.16))
        case .game:
            Capsule().fill(accent.opacity(0.16))
        default:
            Circle().fill(accent.opacity(0.16))
        }
    }

    @ViewBuilder private var mascotOutline: some View {
        switch resolvedExperience {
        case .receipt:
            RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(accent.opacity(0.25), lineWidth: 2)
        case .courtroom:
            RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(CorpPalette.verdictGold.opacity(0.45), lineWidth: 2)
        case .camera, .gallery:
            RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(accent.opacity(0.25), lineWidth: 2)
        case .game:
            Capsule().stroke(accent.opacity(0.25), lineWidth: 2)
        default:
            Circle().stroke(accent.opacity(0.25), lineWidth: 2)
        }
    }

    private var visualSeed: CGFloat {
        let total = eyebrow.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return CGFloat(total % 7)
    }

    private var resolvedPersonality: DumbPersonality {
        if let personality { return personality }
        switch Int(visualSeed) % 4 {
        case 0: return .office
        case 1: return .optimistic
        case 2: return .dramatic
        default: return .chaotic
        }
    }
}

public struct DumbAction: View {
    let title: String
    let accent: Color
    let systemImage: String
    let isLoading: Bool
    let action: () -> Void
    @Environment(\.dumbExperienceStyle) private var experience
    @Environment(\.isEnabled) private var isEnabled

    public init(
        title: String,
        accent: Color,
        systemImage: String = "sparkles",
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.accent = accent
        self.systemImage = systemImage
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button {
            guard isEnabled, !isLoading else { return }
            #if os(iOS)
            DumbHaptics.light()
            #endif
            action()
        } label: {
            HStack(spacing: 10) {
                Group {
                    if isLoading {
                        ProgressView()
                            .tint(CorpPalette.actionInk)
                    } else {
                        Image(systemName: systemImage)
                    }
                }
                .font(.headline.weight(.black))
                .frame(width: 22, height: 22)
                .accessibilityHidden(true)
                Text(title)
                    .font(.headline.weight(.black))
                Spacer()
                if !isLoading {
                    Image(systemName: "arrow.right")
                        .font(.headline.weight(.black))
                        .accessibilityHidden(true)
                }
            }
            .frame(maxWidth: .infinity, minHeight: DumbMetrics.minimumTapTarget)
            .padding(.horizontal, DumbSpacing.md)
            .padding(.vertical, DumbSpacing.sm)
            .foregroundStyle(CorpPalette.actionInk)
            .background(actionBackground)
            .shadow(color: accent.opacity(experience == .receipt ? 0.08 : 0.14), radius: experience == .game ? 4 : 3, y: 2)
        }
        .buttonStyle(DumbPressStyle())
        .accessibilityHint("Runs the app's official nonsense action.")
    }

    @ViewBuilder private var actionBackground: some View {
        switch experience {
        case .receipt:
            RoundedRectangle(cornerRadius: experience.actionRadius, style: .continuous).fill(accent)
        case .game:
            RoundedRectangle(cornerRadius: experience.actionRadius, style: .continuous).fill(accent)
                .overlay(RoundedRectangle(cornerRadius: experience.actionRadius, style: .continuous).stroke(CorpPalette.ink.opacity(0.14), lineWidth: 2))
        case .courtroom:
            RoundedRectangle(cornerRadius: experience.actionRadius, style: .continuous).fill(CorpPalette.courtroomNavy)
                .overlay(RoundedRectangle(cornerRadius: experience.actionRadius, style: .continuous).stroke(CorpPalette.verdictGold.opacity(0.70), lineWidth: 2))
        case .timer:
            Capsule().fill(accent)
        case .journal:
            RoundedRectangle(cornerRadius: experience.actionRadius, style: .continuous).fill(accent.opacity(0.92))
        default:
            RoundedRectangle(cornerRadius: experience.actionRadius, style: .continuous).fill(accent)
        }
    }
}

public struct DumbPressStyle: ButtonStyle {
    public init() {}

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(isEnabled && configuration.isPressed ? 0.97 : 1)
            .opacity(isEnabled ? (configuration.isPressed ? 0.92 : 1) : 0.42)
            .animation(reduceMotion ? nil : DumbMotion.quick, value: configuration.isPressed)
    }
}

public struct DumbCard<Content: View>: View {
    let accent: Color?
    let isSelected: Bool
    let content: Content
    @Environment(\.dumbExperienceStyle) private var experience

    public init(accent: Color? = nil, isSelected: Bool = false, @ViewBuilder content: () -> Content) {
        self.accent = accent
        self.isSelected = isSelected
        self.content = content()
    }

    public var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(experience.cardPadding)
            .background(cardBackground, in: RoundedRectangle(cornerRadius: experience.cardRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: experience.cardRadius, style: .continuous)
                    .stroke(isSelected ? (accent ?? CorpPalette.sunshine) : experience == .courtroom ? CorpPalette.verdictGold.opacity(0.28) : CorpPalette.ink.opacity(0.06), lineWidth: isSelected || experience == .courtroom ? 2 : 1)
            }
            .shadow(color: CorpPalette.ink.opacity(isSelected ? 0.08 : experience == .receipt ? 0.02 : 0.035), radius: min(experience.cardShadowRadius, 8), y: min(experience.cardShadowY, 4))
    }

    private var cardBackground: Color {
        guard isSelected, let accent else {
            switch experience {
            case .receipt: return CorpPalette.receiptCream.opacity(0.52)
            case .journal: return CorpPalette.surface.opacity(0.94)
            default: return CorpPalette.surface
            }
        }
        return accent.opacity(0.13)
    }
}

public struct DumbStatusPill: View {
    let title: String
    let systemImage: String
    let accent: Color

    public init(_ title: String, systemImage: String, accent: Color) {
        self.title = title
        self.systemImage = systemImage
        self.accent = accent
    }

    public var body: some View {
        Label(title, systemImage: systemImage)
            .font(.caption2.weight(.black))
            .tracking(0.8)
            .foregroundStyle(CorpPalette.ink.opacity(0.72))
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(accent.opacity(0.15), in: Capsule())
    }
}

public struct DumbCharacterStage: View {
    let assetName: String
    let accent: Color
    let title: String
    let caption: String
    let reactionTrigger: Int
    let reactionStyle: DumbReactionStyle

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dumbExperienceStyle) private var experience

    public init(
        assetName: String = "AppMascot",
        accent: Color,
        title: String,
        caption: String,
        reactionTrigger: Int,
        reactionStyle: DumbReactionStyle = .bounce
    ) {
        self.assetName = assetName
        self.accent = accent
        self.title = title
        self.caption = caption
        self.reactionTrigger = reactionTrigger
        self.reactionStyle = reactionStyle
    }

    public var body: some View {
        HStack(alignment: .center, spacing: DumbSpacing.md) {
            ZStack {
                mascotBackdrop
                Image(assetName, bundle: .main)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 78, height: 78)
                    .phaseAnimator(reduceMotion ? [.rest] : DumbReactionPhase.sequence, trigger: reactionTrigger) { content, phase in
                        content
                            .scaleEffect(scale(for: phase))
                            .rotationEffect(.degrees(rotation(for: phase)))
                            .offset(x: xOffset(for: phase), y: yOffset(for: phase))
                    } animation: { phase in
                        animation(for: phase)
                    }
            }
            .frame(width: 82, height: 82)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 5) {
                Text(title.uppercased())
                    .font(.caption2.weight(.black))
                    .tracking(1.25)
                    .foregroundStyle(accent)
                Text(caption)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CorpPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .contentTransition(.opacity)
            }
            Spacer(minLength: 0)
        }
        .padding(DumbSpacing.md)
        .background(CorpPalette.surface, in: RoundedRectangle(cornerRadius: stageRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: stageRadius, style: .continuous)
                .stroke(accent.opacity(0.16), lineWidth: 1)
        }
        .shadow(color: CorpPalette.ink.opacity(0.035), radius: 8, y: 4)
        .animation(reduceMotion ? nil : DumbMotion.quick, value: caption)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title). \(caption)")
    }

    private var stageRadius: CGFloat {
        min(max(experience.cardRadius, 14), 24)
    }

    @ViewBuilder private var mascotBackdrop: some View {
        switch experience {
        case .receipt:
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(CorpPalette.receiptCream.opacity(0.62))
        case .courtroom:
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(CorpPalette.verdictGold.opacity(0.16))
        case .game:
            Circle().fill(accent.opacity(0.16))
        default:
            Circle().fill(accent.opacity(0.13))
        }
    }

    private func scale(for phase: DumbReactionPhase) -> CGFloat {
        guard !reduceMotion else { return 1 }
        switch (reactionStyle, phase) {
        case (_, .rest): return 1
        case (.bounce, .anticipate): return 0.94
        case (.bounce, .payoff): return 1.05
        case (.shake, .anticipate): return 0.98
        case (.shake, .payoff): return 1.02
        case (.stamp, .anticipate): return 1.04
        case (.stamp, .payoff): return 0.96
        }
    }

    private func rotation(for phase: DumbReactionPhase) -> Double {
        guard !reduceMotion else { return 0 }
        switch (reactionStyle, phase) {
        case (.bounce, .anticipate): return -2
        case (.bounce, .payoff): return 2
        case (.shake, .anticipate): return -6
        case (.shake, .payoff): return 6
        case (.stamp, .anticipate): return -1
        case (.stamp, .payoff): return 1
        default: return 0
        }
    }

    private func xOffset(for phase: DumbReactionPhase) -> CGFloat {
        guard !reduceMotion, reactionStyle == .shake else { return 0 }
        switch phase {
        case .anticipate: return -10
        case .payoff: return 10
        case .rest: return 0
        }
    }

    private func yOffset(for phase: DumbReactionPhase) -> CGFloat {
        guard !reduceMotion else { return 0 }
        switch (reactionStyle, phase) {
        case (.bounce, .anticipate): return 7
        case (.bounce, .payoff): return -12
        case (.stamp, .anticipate): return -7
        case (.stamp, .payoff): return 5
        default: return 0
        }
    }

    private func animation(for phase: DumbReactionPhase) -> Animation? {
        guard !reduceMotion else { return nil }
        switch phase {
        case .rest: return DumbMotion.settle
        case .anticipate: return .easeIn(duration: 0.12)
        case .payoff: return DumbMotion.playful
        }
    }
}

public struct DumbField: View {
    let label: String
    let axis: Axis
    let maxLength: Int
    @Binding var text: String
    @FocusState private var isFocused: Bool
    @Environment(\.dumbExperienceStyle) private var experience

    public init(_ label: String, axis: Axis = .horizontal, maxLength: Int = 240, text: Binding<String>) {
        self.label = label
        self.axis = axis
        self.maxLength = max(1, maxLength)
        self._text = text
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.caption2.weight(.black))
                .tracking(1.1)
                .foregroundStyle(CorpPalette.mutedInk)
                .accessibilityHidden(true)
            TextField("Enter \(label.lowercased())", text: $text, axis: axis)
                .font(.body.weight(.bold))
                .focused($isFocused)
                .padding(.horizontal, DumbSpacing.sm)
                .padding(.vertical, 11)
                .frame(minHeight: DumbMetrics.minimumTapTarget)
                .background(CorpPalette.canvas, in: RoundedRectangle(cornerRadius: inputRadius, style: .continuous))
                .accessibilityLabel(label)
                .accessibilityHint("Enter up to \(maxLength) characters.")
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") { isFocused = false }
                            .fontWeight(.semibold)
                    }
                }
                .onChange(of: text) { _, newValue in
                    guard newValue.count > maxLength else { return }
                    text = String(newValue.prefix(maxLength))
                }
        }
    }

    private var inputRadius: CGFloat {
        switch experience {
        case .receipt: return 8
        case .courtroom, .journal: return 11
        case .game: return 20
        case .camera, .gallery, .wellness: return 16
        default: return 15
        }
    }
}

/// A native disclosure section with one surface — avoids card-inside-disclosure nesting.
public struct DumbDisclosureSection<Content: View>: View {
    let title: String
    let systemImage: String
    @Binding var isExpanded: Bool
    let accent: Color?
    @ViewBuilder let content: Content
    @Environment(\.dumbExperienceStyle) private var experience

    public init(
        _ title: String,
        systemImage: String,
        isExpanded: Binding<Bool>,
        accent: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.systemImage = systemImage
        self._isExpanded = isExpanded
        self.accent = accent
        self.content = content()
    }

    public var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            content
                .padding(.top, DumbSpacing.sm)
        } label: {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.black))
                .foregroundStyle(CorpPalette.ink)
        }
        .padding(experience.cardPadding)
        .background(CorpPalette.surface, in: RoundedRectangle(cornerRadius: experience.cardRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: experience.cardRadius, style: .continuous)
                .stroke(
                    accent?.opacity(0.22) ?? CorpPalette.ink.opacity(0.06),
                    lineWidth: accent == nil ? 1 : 1.5
                )
        }
        .shadow(color: CorpPalette.ink.opacity(0.035), radius: min(experience.cardShadowRadius, 8), y: min(experience.cardShadowY, 4))
    }
}

public struct DumbSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let accent: Color

    public init(title: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double = 1, accent: Color) {
        self.title = title
        self._value = value
        self.range = range
        self.step = step
        self.accent = accent
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("\(title): \(displayedValue)")
                .font(.subheadline.weight(.black))
                .accessibilityHidden(true)
            Slider(value: $value, in: range, step: step)
                .tint(accent)
                .accessibilityLabel(title)
                .accessibilityValue(displayedValue)
        }
    }

    private var displayedValue: String {
        value == value.rounded() ? "\(Int(value))" : String(format: "%.1f", value)
    }
}

public struct DumbResult: View {
    let text: String
    let accent: Color
    let systemImage: String
    let reactionStyle: DumbReactionStyle
    @Environment(\.dumbExperienceStyle) private var experience
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        text: String,
        accent: Color = CorpPalette.sunshine,
        systemImage: String = "seal.fill",
        reactionStyle: DumbReactionStyle = .stamp
    ) {
        self.text = text
        self.accent = accent
        self.systemImage = systemImage
        self.reactionStyle = reactionStyle
    }

    public var body: some View {
        DumbCard(accent: accent) {
            VStack(alignment: .leading, spacing: 9) {
                HStack(spacing: 8) {
                    Image(systemName: systemImage)
                        .foregroundStyle(accent)
                        .accessibilityHidden(true)
                    Text(experience.resultLabel)
                        .font(.caption2.weight(.black))
                        .tracking(1.2)
                        .foregroundStyle(CorpPalette.mutedInk)
                }
                Text(text)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(CorpPalette.ink)
                    .contentTransition(.opacity)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Official result")
        .accessibilityValue(text)
        .phaseAnimator(reduceMotion ? [.rest] : DumbReactionPhase.sequence, trigger: text) { content, phase in
            content
                .scaleEffect(resultScale(for: phase))
                .rotationEffect(.degrees(resultRotation(for: phase)))
        } animation: { phase in
            guard !reduceMotion else { return nil }
            return phase == .anticipate ? .easeIn(duration: 0.10) : DumbMotion.quick
        }
        .animation(reduceMotion ? nil : DumbMotion.quick, value: text)
        .onChange(of: text) { oldValue, newValue in
            guard oldValue != newValue, reactionStyle != .bounce else { return }
            DumbHaptics.verdict()
        }
    }

    private func resultScale(for phase: DumbReactionPhase) -> CGFloat {
        guard !reduceMotion else { return 1 }
        switch phase {
        case .rest: return 1
        case .anticipate: return reactionStyle == .stamp ? 1.025 : 0.98
        case .payoff: return reactionStyle == .stamp ? 0.985 : 1.02
        }
    }

    private func resultRotation(for phase: DumbReactionPhase) -> Double {
        guard !reduceMotion, reactionStyle == .shake else { return 0 }
        switch phase {
        case .rest: return 0
        case .anticipate: return -1.5
        case .payoff: return 1.5
        }
    }
}

#if os(iOS)
public enum DumbHaptics {
    public static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    public static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    public static func verdict() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
#else
public enum DumbHaptics {
    public static func light() {}
    public static func medium() {}
    public static func verdict() {}
}
#endif

/// Dismissible first-run boundary for health, generative, or permission-sensitive apps.
public struct DumbBoundaryChip: View {
    let storageKey: String
    let message: String
    let accent: Color
    let systemImage: String

    @AppStorage private var isDismissed: Bool

    public init(
        storageKey: String,
        message: String,
        accent: Color,
        systemImage: String = "info.circle.fill"
    ) {
        self.storageKey = storageKey
        self.message = message
        self.accent = accent
        self.systemImage = systemImage
        _isDismissed = AppStorage(wrappedValue: false, storageKey)
    }

    public var body: some View {
        if !isDismissed {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: systemImage)
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(accent)
                    .accessibilityHidden(true)
                Text(message)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CorpPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
                Button {
                    withAnimation(.snappy) { isDismissed = true }
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption.weight(.black))
                        .frame(width: DumbMetrics.minimumTapTarget, height: DumbMetrics.minimumTapTarget)
                }
                .foregroundStyle(CorpPalette.mutedInk)
                .buttonStyle(DumbPressStyle())
                .accessibilityLabel("Dismiss boundary note")
            }
            .padding(DumbSpacing.sm)
            .background(accent.opacity(0.10), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(accent.opacity(0.22), lineWidth: 1)
            }
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("boundaryChip")
        }
    }
}

/// Visual empty-state invite — premise + optional action, not a dead label.
public struct DumbEmptyInvite: View {
    let title: String
    let message: String
    let systemImage: String
    let accent: Color
    let actionTitle: String?
    let action: (() -> Void)?

    public init(
        title: String,
        message: String,
        systemImage: String,
        accent: Color,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.accent = accent
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: DumbSpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 36, weight: .black))
                .foregroundStyle(accent)
                .frame(width: 72, height: 72)
                .background(accent.opacity(0.12), in: Circle())
                .accessibilityHidden(true)
            Text(title)
                .font(.headline.weight(.black))
                .foregroundStyle(CorpPalette.ink)
                .multilineTextAlignment(.center)
            Text(message)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CorpPalette.mutedInk)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline.weight(.black))
                        .frame(maxWidth: .infinity, minHeight: DumbMetrics.minimumTapTarget)
                }
                .foregroundStyle(accent)
                .buttonStyle(DumbPressStyle())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DumbSpacing.lg)
        .background(CorpPalette.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(accent.opacity(0.14), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }
}

/// One-tap share for receipts, verdicts, and autopsy text.
public struct DumbShareVerdict: View {
    let text: String
    let subject: String
    let accent: Color
    let systemImage: String
    let accessibilityIdentifier: String?

    public init(
        text: String,
        subject: String,
        accent: Color,
        systemImage: String = "square.and.arrow.up",
        accessibilityIdentifier: String? = nil
    ) {
        self.text = text
        self.subject = subject
        self.accent = accent
        self.systemImage = systemImage
        self.accessibilityIdentifier = accessibilityIdentifier
    }

    public var body: some View {
        ShareLink(item: text, subject: Text(subject), message: Text(text)) {
            Label("Share this result", systemImage: systemImage)
                .font(.subheadline.weight(.black))
                .frame(maxWidth: .infinity, minHeight: DumbMetrics.minimumTapTarget)
        }
        .foregroundStyle(accent)
        .buttonStyle(DumbPressStyle())
        .accessibilityIdentifier(accessibilityIdentifier ?? "shareVerdictButton")
        .accessibilityHint("Opens the share sheet with the current result.")
    }
}

public enum DumbHeroMeterVariant {
    case arc
    case chairs
    case invoice
}

/// Large hero gauge for meter-lane apps — distinct compositions without a shared template shell.
public struct DumbHeroMeter: View {
    let progress: Double
    let valueLabel: String
    let title: String
    let subtitle: String?
    let accent: Color
    let systemImage: String
    let variant: DumbHeroMeterVariant
    let size: CGFloat

    public init(
        progress: Double,
        valueLabel: String,
        title: String,
        subtitle: String? = nil,
        accent: Color,
        systemImage: String,
        variant: DumbHeroMeterVariant = .arc,
        size: CGFloat = 112
    ) {
        self.progress = min(max(progress, 0), 1)
        self.valueLabel = valueLabel
        self.title = title
        self.subtitle = subtitle
        self.accent = accent
        self.systemImage = systemImage
        self.variant = variant
        self.size = size
    }

    public var body: some View {
        HStack(spacing: DumbSpacing.md) {
            meterVisual
                .frame(width: size, height: size)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text(title.uppercased())
                    .font(.caption2.weight(.black))
                    .tracking(1.1)
                    .foregroundStyle(accent)
                Text(valueLabel)
                    .font(.system(.title, design: .rounded).weight(.black))
                    .foregroundStyle(CorpPalette.ink)
                    .minimumScaleFactor(0.7)
                    .lineLimit(2)
                    .contentTransition(.numericText())
                if let subtitle {
                    Text(subtitle)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CorpPalette.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(DumbSpacing.md)
        .background(CorpPalette.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(accent.opacity(0.16), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue("\(valueLabel). \(subtitle ?? "")")
    }

    @ViewBuilder private var meterVisual: some View {
        switch variant {
        case .arc:
            ZStack {
                Circle()
                    .stroke(accent.opacity(0.14), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(accent, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Image(systemName: systemImage)
                    .font(.title2.weight(.black))
                    .foregroundStyle(accent)
            }
        case .chairs:
            VStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { col in
                            let index = row * 3 + col
                            let filled = Double(index) / 8.0 <= progress
                            Image(systemName: filled ? "chair.lounge.fill" : "chair.lounge")
                                .font(.caption.weight(.black))
                                .foregroundStyle(filled ? accent : accent.opacity(0.22))
                        }
                    }
                }
            }
        case .invoice:
            VStack(spacing: 0) {
                Rectangle()
                    .fill(accent)
                    .frame(height: 4)
                VStack(spacing: 6) {
                    Image(systemName: systemImage)
                        .font(.title3.weight(.black))
                        .foregroundStyle(accent)
                    Text(valueLabel)
                        .font(.caption.weight(.black).monospaced())
                        .foregroundStyle(CorpPalette.ink)
                        .minimumScaleFactor(0.6)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                .padding(10)
            }
            .background(CorpPalette.receiptCream, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(accent.opacity(0.35), lineWidth: 1)
            }
            .rotationEffect(.degrees(-2))
        }
    }
}

#if os(iOS)
/// A small native camera bridge shared by the photo-led apps.
/// The caller owns presentation state so the sheet can dismiss immediately after capture.
public struct DumbCameraPicker: UIViewControllerRepresentable {
    private let onImage: (UIImage) -> Void
    private let onCancel: () -> Void

    public init(onImage: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
        self.onImage = onImage
        self.onCancel = onCancel
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(onImage: onImage, onCancel: onCancel)
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_ controller: UIImagePickerController, context: Context) {}

    public final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        private let onImage: (UIImage) -> Void
        private let onCancel: () -> Void

        init(onImage: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
            self.onImage = onImage
            self.onCancel = onCancel
        }

        public func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            guard let image = info[.originalImage] as? UIImage else {
                onCancel()
                return
            }
            onImage(image)
        }

        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onCancel()
        }
    }
}
#endif
