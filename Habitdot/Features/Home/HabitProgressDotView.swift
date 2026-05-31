import SwiftUI

struct HabitProgressDotView: View {
    let color: Color
    let isComplete: Bool
    let isFuture: Bool

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(color.opacity(isFuture ? 0.35 : 0.95), lineWidth: 1.7)
                .background {
                    Circle()
                        .fill(isComplete ? color : .clear)
                }
                .frame(width: 18, height: 18)

            if isComplete {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .scaleEffect(isComplete ? 1.06 : 1)
    }
}
