import SwiftUI

struct GridDashboardView: View {
    @Environment(HabitStore.self) private var store
    let proAction: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                GridPeriodPickerView(proAction: proAction)
                GridDateNavigatorView()

                if store.accessibleActiveHabits.isEmpty {
                    EmptyHabitStartView()
                        .padding(.top, 14)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(store.accessibleActiveHabits) { habit in
                            GridHabitCardView(habit: habit)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 76)
            .padding(.bottom, 122)
        }
        .onAppear(perform: keepFreeUsersOutOfQuarterlyStats)
        .onChange(of: store.isProUnlocked) { _, _ in
            keepFreeUsersOutOfQuarterlyStats()
        }
    }

    private func keepFreeUsersOutOfQuarterlyStats() {
        guard !store.isProUnlocked, store.gridPeriod == .quarterly else { return }
        store.gridPeriod = .weekly
    }
}
