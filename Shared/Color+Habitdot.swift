import SwiftUI

extension Color {
    static let habitdotBackground = Color(.systemGroupedBackground)
    static let habitdotCard = Color(.secondarySystemGroupedBackground)
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
}
