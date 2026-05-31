import SwiftUI

struct HabitdotCardModifier: ViewModifier {
    private let shape = RoundedRectangle(cornerRadius: 19, style: .continuous)

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .background {
                    shape
                        .fill(Color.habitdotCard.opacity(0.82))
                        .habitdotFloatingSurface(shape)
                }
                .overlay {
                    shape
                        .stroke(.white.opacity(0.28), lineWidth: 0.8)
                }
                .shadow(color: .black.opacity(0.045), radius: 14, y: 5)
        } else {
            content
                .background(Color.habitdotCard, in: shape)
                .shadow(color: .black.opacity(0.02), radius: 8, y: 2)
        }
    }
}

extension View {
    func habitdotCard() -> some View {
        modifier(HabitdotCardModifier())
    }
}
