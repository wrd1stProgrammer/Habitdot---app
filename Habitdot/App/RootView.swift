import SwiftUI

struct RootView: View {
    @Environment(HabitStore.self) private var store
    @Environment(HabitdotPurchaseStore.self) private var purchaseStore
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("onboarding.completed") private var onboardingCompleted = false
    @AppStorage(AppLanguage.storageKey) private var appLanguageRawValue = AppLanguage.englishUS.rawValue

    var body: some View {
        Group {
            if shouldShowOnboarding {
                OnboardingView { payload in
                    completeOnboarding(payload)
                }
                .preferredColorScheme(.light)
            } else {
                MainTabShellView()
                    .preferredColorScheme(store.snapshot.settings.appearance.colorScheme)
            }
        }
        .environment(\.locale, appLanguage.locale)
        .task {
            syncOnboardingCompletionCacheIfNeeded()
            store.rescheduleReminders()
            purchaseStore.isProUnlocked = store.isProUnlocked
            let isUnlocked = await purchaseStore.refreshEntitlementStatus()
            store.setProUnlocked(isUnlocked)
        }
        .onChange(of: purchaseStore.isProUnlocked) { _, isUnlocked in
            store.setProUnlocked(isUnlocked)
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            store.reloadSnapshotFromSharedStorageIfNeeded()
            store.refreshForCurrentLocalDayIfNeeded()
            syncOnboardingCompletionCacheIfNeeded()
            Task {
                purchaseStore.isProUnlocked = store.isProUnlocked
                let isUnlocked = await purchaseStore.refreshEntitlementStatus()
                store.setProUnlocked(isUnlocked)
            }
        }
    }

    private var appLanguage: AppLanguage {
        AppLanguage.selected(from: appLanguageRawValue)
    }

    private var shouldShowOnboarding: Bool {
        !onboardingCompleted
    }

    private func completeOnboarding(_ payload: OnboardingCompletionPayload) {
        store.finishOnboarding(payload)
        onboardingCompleted = true
    }

    private func syncOnboardingCompletionCacheIfNeeded() {
        guard !onboardingCompleted, store.snapshot.settings.onboardingCompletedAt != nil else { return }
        onboardingCompleted = true
    }
}
