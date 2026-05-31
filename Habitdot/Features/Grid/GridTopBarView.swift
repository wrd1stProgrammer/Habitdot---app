import SwiftUI

struct GridTopBarView: View {
    @Environment(HabitStore.self) private var store

    var body: some View {
        HStack(spacing: 12) {
            Spacer()

            Button("grid.dots", systemImage: "square.grid.3x3.fill", action: showDots)
                .labelStyle(.iconOnly)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(store.gridDisplayMode == .dots ? Color.habitdotAccent : Color.habitdotSecondaryText)
                .frame(width: 38, height: 38)
                .background {
                    if store.gridDisplayMode == .dots {
                        Circle()
                            .fill(Color.habitdotCard)
                            .habitdotFloatingSurface(Circle())
                    }
                }

            Button("grid.edit", systemImage: "pencil", action: showCalendar)
                .labelStyle(.iconOnly)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(store.gridDisplayMode == .calendar ? Color.habitdotAccent : Color.habitdotSecondaryText)
                .frame(width: 38, height: 38)
                .background {
                    if store.gridDisplayMode == .calendar {
                        Circle()
                            .fill(Color.habitdotCard)
                            .habitdotFloatingSurface(Circle())
                    }
                }
        }
    }

    private func showCalendar() {
        store.triggerFeedback()
        withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
            store.gridDisplayMode = .calendar
        }
    }

    private func showDots() {
        store.triggerFeedback()
        withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
            store.gridDisplayMode = .dots
        }
    }
}
