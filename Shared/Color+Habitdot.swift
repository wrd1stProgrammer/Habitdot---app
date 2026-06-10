import SwiftUI
import UIKit

extension Color {
    static let habitdotBackground = dynamic(light: .systemGroupedBackground, dark: UIColor(hex: 0x000000))
    static let habitdotCard = dynamic(light: .secondarySystemGroupedBackground, dark: UIColor(hex: 0x050505))
    static let habitdotElevatedSurface = dynamic(light: .secondarySystemGroupedBackground, dark: UIColor(hex: 0x181819))
    static let habitdotSelectedSurface = dynamic(light: .systemGray5, dark: UIColor(hex: 0x3A3A3A))
    static let habitdotSubtleStroke = dynamic(light: UIColor(white: 0, alpha: 0.06), dark: UIColor(hex: 0x1D1D1F))
    static let habitdotControlStroke = dynamic(light: UIColor(white: 1, alpha: 0.62), dark: UIColor(hex: 0x2B2B2D))
    static let habitdotMutedDot = dynamic(light: .systemGray5, dark: UIColor(hex: 0x151516))
    static let habitdotCalendarMutedDot = dynamic(light: .systemGray6, dark: UIColor(hex: 0x18181A))
    static let habitdotInk = Color(.label)
    static let habitdotSecondaryText = Color(.secondaryLabel)
    static let habitdotTertiaryText = Color(.tertiaryLabel)
    static let habitdotAccent = Color(red: 0.94, green: 0.22, blue: 0.32)
    static let habitdotPink = Color(red: 1.00, green: 0.34, blue: 0.50)
    static let habitdotOnboardingBackground = Color(red: 0.965, green: 0.968, blue: 0.976)
    static let habitdotOnboardingTrack = Color(red: 0.86, green: 0.87, blue: 0.90)
    static let habitdotOnboardingAccent = Color.habitdotIndigo
    static let habitdotWidgetBackground = Color(red: 0.02, green: 0.02, blue: 0.02)
    static let habitdotWidgetMutedDot = Color(red: 0.16, green: 0.16, blue: 0.16)
    static let habitdotAmber = Color(red: 0.97, green: 0.70, blue: 0.20)
    static let habitdotRose = Color(red: 0.95, green: 0.28, blue: 0.41)
    static let habitdotIndigo = Color(red: 0.38, green: 0.34, blue: 0.85)
    static let habitdotMint = Color(red: 0.18, green: 0.78, blue: 0.60)
    static let habitdotViolet = Color(red: 0.61, green: 0.36, blue: 0.90)
    static let habitdotBrown = Color(red: 0.63, green: 0.42, blue: 0.30)
    static let habitdotBlue = Color(red: 0.24, green: 0.55, blue: 1.00)

    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }

    private static func dynamic(light: UIColor, dark: UIColor) -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? dark : light
        })
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
