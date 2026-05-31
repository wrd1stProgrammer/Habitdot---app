import SwiftUI

struct GridPeriodPickerView: View {
    @Environment(HabitStore.self) private var store
    @Namespace private var periodNamespace
    let proAction: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(HabitGridPeriod.allCases) { period in
                Button(action: { select(period) }) {
                    HStack(spacing: 4) {
                        Text(HabitdotDisplayText.periodTitle(period))
                            .lineLimit(1)

                        if isLocked(period) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 9, weight: .bold))
                        }
                    }
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(store.gridPeriod == period ? Color.habitdotInk : Color.habitdotSecondaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 34)
                    .background {
                        if store.gridPeriod == period {
                            Capsule()
                                .fill(Color.habitdotCard)
                                .matchedGeometryEffect(id: "gridPeriodSelection", in: periodNamespace)
                                .habitdotFloatingSurface(Capsule())
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(store.gridPeriod == period ? [.isSelected] : [])
            }
        }
        .padding(.horizontal, 30)
    }

    private func isLocked(_ period: HabitGridPeriod) -> Bool {
        !store.isProUnlocked && period == .quarterly
    }

    private func select(_ period: HabitGridPeriod) {
        store.triggerFeedback()

        guard !isLocked(period) else {
            proAction()
            return
        }

        withAnimation(.spring(response: 0.36, dampingFraction: 0.84)) {
            store.gridPeriod = period
        }
    }
}
