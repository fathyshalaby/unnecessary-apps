import SwiftUI

#if os(iOS)
import UIKit
#endif

private struct CorpRGB {
    let red: Double
    let green: Double
    let blue: Double
}

#if os(iOS)
private func adaptiveColor(light: CorpRGB, dark: CorpRGB) -> Color {
    Color(UIColor { traits in
        let value = traits.userInterfaceStyle == .dark ? dark : light
        return UIColor(red: value.red, green: value.green, blue: value.blue, alpha: 1)
    })
}
#else
private func adaptiveColor(light: CorpRGB, dark: CorpRGB) -> Color {
    Color(red: light.red, green: light.green, blue: light.blue)
}
#endif

public enum CorpPalette {
    public static let canvas = adaptiveColor(
        light: CorpRGB(red: 0.98, green: 0.96, blue: 0.91),
        dark: CorpRGB(red: 0.08, green: 0.07, blue: 0.10)
    )
    public static let surface = adaptiveColor(
        light: CorpRGB(red: 1.00, green: 1.00, blue: 1.00),
        dark: CorpRGB(red: 0.15, green: 0.13, blue: 0.18)
    ).opacity(0.96)
    public static let ink = adaptiveColor(
        light: CorpRGB(red: 0.08, green: 0.08, blue: 0.11),
        dark: CorpRGB(red: 1.00, green: 0.98, blue: 0.93)
    )
    public static let mutedInk = adaptiveColor(
        light: CorpRGB(red: 0.38, green: 0.37, blue: 0.38),
        dark: CorpRGB(red: 0.78, green: 0.75, blue: 0.79)
    )
    public static let sunshine = adaptiveColor(
        light: CorpRGB(red: 1.00, green: 0.75, blue: 0.18),
        dark: CorpRGB(red: 1.00, green: 0.82, blue: 0.30)
    )
    public static let coral = adaptiveColor(
        light: CorpRGB(red: 0.96, green: 0.29, blue: 0.25),
        dark: CorpRGB(red: 1.00, green: 0.47, blue: 0.43)
    )
    public static let sky = adaptiveColor(
        light: CorpRGB(red: 0.26, green: 0.68, blue: 0.93),
        dark: CorpRGB(red: 0.42, green: 0.77, blue: 1.00)
    )
    public static let violet = adaptiveColor(
        light: CorpRGB(red: 0.51, green: 0.38, blue: 0.88),
        dark: CorpRGB(red: 0.65, green: 0.56, blue: 1.00)
    )
    public static let parkGreen = adaptiveColor(
        light: CorpRGB(red: 0.16, green: 0.48, blue: 0.29),
        dark: CorpRGB(red: 0.38, green: 0.78, blue: 0.52)
    )
    public static let bathroomBlue = adaptiveColor(
        light: CorpRGB(red: 0.08, green: 0.42, blue: 0.65),
        dark: CorpRGB(red: 0.35, green: 0.72, blue: 1.00)
    )
    public static let emergencyRed = adaptiveColor(
        light: CorpRGB(red: 0.80, green: 0.10, blue: 0.12),
        dark: CorpRGB(red: 1.00, green: 0.42, blue: 0.45)
    )
    public static let receiptCream = adaptiveColor(
        light: CorpRGB(red: 0.96, green: 0.92, blue: 0.78),
        dark: CorpRGB(red: 0.98, green: 0.84, blue: 0.50)
    )
    public static let evidenceMint = adaptiveColor(
        light: CorpRGB(red: 0.70, green: 0.90, blue: 0.82),
        dark: CorpRGB(red: 0.42, green: 0.88, blue: 0.68)
    )
    public static let warningRed = adaptiveColor(
        light: CorpRGB(red: 0.75, green: 0.17, blue: 0.12),
        dark: CorpRGB(red: 1.00, green: 0.40, blue: 0.34)
    )
    public static let courtroomNavy = adaptiveColor(
        light: CorpRGB(red: 0.08, green: 0.13, blue: 0.27),
        dark: CorpRGB(red: 0.48, green: 0.63, blue: 1.00)
    )
    public static let verdictGold = adaptiveColor(
        light: CorpRGB(red: 0.88, green: 0.58, blue: 0.12),
        dark: CorpRGB(red: 1.00, green: 0.78, blue: 0.32)
    )
    public static let detergentBlue = adaptiveColor(
        light: CorpRGB(red: 0.16, green: 0.54, blue: 0.78),
        dark: CorpRGB(red: 0.38, green: 0.76, blue: 1.00)
    )
    public static let sleepyLavender = adaptiveColor(
        light: CorpRGB(red: 0.54, green: 0.47, blue: 0.78),
        dark: CorpRGB(red: 0.72, green: 0.66, blue: 1.00)
    )
    public static let actionInk = adaptiveColor(
        light: CorpRGB(red: 1.00, green: 1.00, blue: 1.00),
        dark: CorpRGB(red: 0.08, green: 0.07, blue: 0.10)
    )
}
