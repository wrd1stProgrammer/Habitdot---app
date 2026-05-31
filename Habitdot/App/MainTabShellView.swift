import SwiftUI

struct MainTabShellView: View {
    @Environment(HabitStore.self) private var store
    @Environment(HabitdotPurchaseStore.self) private var purchaseStore
    @State private var activeSheet: HabitdotSheet?
    @State private var isPaywallPresented = false
    @State private var isPreparingPaywall = false

    var body: some View {
        ZStack {
            Group {
                switch store.selectedTab {
                case .today, .add:
                    TodayView(editHabitAction: { activeSheet = .editHabit($0.id) })
                case .grid:
                    GridDashboardView(proAction: { isPaywallPresented = true })
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack {
                ShellHeaderActionsView(
                    isProUnlocked: store.isProUnlocked,
                    isLoadingPro: isPreparingPaywall || purchaseStore.isLoadingOfferings,
                    proAction: prepareAndPresentPaywall,
                    settingsAction: { activeSheet = .settings }
                )
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                Spacer()
            }

            VStack {
                Spacer()
                BottomTabBarView { tab in
                    if tab == .add {
                        store.triggerFeedback()
                        if store.canCreateHabit {
                            activeSheet = .addHabit
                        } else {
                            isPaywallPresented = true
                        }
                    } else if tab != store.selectedTab {
                        store.triggerFeedback()
                        withAnimation(.snappy(duration: 0.3, extraBounce: 0.1)) {
                            store.selectedTab = tab
                        }
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .background(Color.habitdotBackground.ignoresSafeArea())
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .addHabit:
                AddHabitSheetView(proAction: presentPaywallFromSheet)
                    .presentationDetents([.height(500), .large])
                    .presentationCornerRadius(34)
            case .editHabit(let habitID):
                if let habit = store.snapshot.habits.first(where: { $0.id == habitID }) {
                    AddHabitSheetView(editingHabit: habit, proAction: presentPaywallFromSheet)
                        .presentationDetents([.height(500), .large])
                        .presentationCornerRadius(34)
                }
            case .settings:
                SettingsSheetView(proAction: presentPaywallFromSettings)
                    .presentationDetents([.large])
                    .presentationCornerRadius(38)
            }
        }
        .fullScreenCover(isPresented: $isPaywallPresented) {
            PaywallView(
                onClose: { isPaywallPresented = false },
                onStart: { isPaywallPresented = false }
            )
        }
        .sensoryFeedback(.selection, trigger: store.feedbackTrigger)
    }

    private func presentPaywallFromSettings() {
        activeSheet = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            isPaywallPresented = true
        }
    }

    private func presentPaywallFromSheet() {
        activeSheet = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            isPaywallPresented = true
        }
    }

    private func prepareAndPresentPaywall() {
        guard !store.isProUnlocked, !isPreparingPaywall else { return }

        Task {
            isPreparingPaywall = true
            if purchaseStore.priceTextByPlanID.isEmpty {
                await purchaseStore.loadPaywallData()
                store.setProUnlocked(purchaseStore.isProUnlocked)
            }
            isPreparingPaywall = false
            guard !store.isProUnlocked else { return }
            isPaywallPresented = true
        }
    }
}
