import SwiftUI

private struct HabitdotFloatingSurfaceModifier<S: Shape>: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    let shape: S

    @ViewBuilder
    func body(content: Content) -> some View {
        if colorScheme == .dark {
            content
                .background(Color.habitdotElevatedSurface, in: shape)
                .overlay {
                    shape.stroke(Color.habitdotControlStroke, lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.30), radius: 18, y: 10)
        } else if #available(iOS 26.0, *) {
            content.glassEffect(.regular, in: shape)
        } else {
            content
                .background(.ultraThinMaterial, in: shape)
                .overlay {
                    shape.stroke(.white.opacity(0.62), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.10), radius: 24, y: 12)
        }
    }
}

extension View {
    func habitdotFloatingSurface<S: Shape>(_ shape: S) -> some View {
        modifier(HabitdotFloatingSurfaceModifier(shape: shape))
    }
}
