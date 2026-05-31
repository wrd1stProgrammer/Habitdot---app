import SwiftUI

extension View {
    @ViewBuilder
    func habitdotFloatingSurface<S: Shape>(_ shape: S) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: shape)
        } else {
            self
                .background(.ultraThinMaterial, in: shape)
                .overlay {
                    shape.stroke(.white.opacity(0.62), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.10), radius: 24, y: 12)
        }
    }
}
