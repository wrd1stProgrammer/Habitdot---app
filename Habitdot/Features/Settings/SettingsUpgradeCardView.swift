import SwiftUI

struct SettingsUpgradeCardView: View {
    var action: () -> Void = {}

    var body: some View {
        VStack(spacing: 12) {
            Text("settings.pro.title")
                .font(.system(size: 19, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.habitdotInk)

            Text("settings.pro.subtitle")
                .font(.system(size: 15, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.habitdotSecondaryText)

            Button("settings.pro.button", action: action)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 30)
                .frame(height: 46)
                .background(
                    LinearGradient(colors: [Color(hex: 0x4FB4FF), Color(hex: 0x1D6DFF)], startPoint: .leading, endPoint: .trailing),
                    in: Capsule()
                )
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .habitdotCard()
    }
}
