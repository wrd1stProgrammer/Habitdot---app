import SwiftUI

struct HabitdotGradientButtonStyle: ButtonStyle {
    var isEnabled = true
    var enabledColors = [Color.habitdotAccent, Color.habitdotPink]
    var height: CGFloat = 58

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background {
                Capsule()
                    .fill(
                        isEnabled
                        ? LinearGradient(colors: enabledColors, startPoint: .leading, endPoint: .trailing)
                        : LinearGradient(colors: [.gray.opacity(0.45), .gray.opacity(0.45)], startPoint: .leading, endPoint: .trailing)
                    )
            }
            .scaleEffect(configuration.isPressed && isEnabled ? 0.98 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}
