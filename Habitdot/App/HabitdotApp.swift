import SwiftUI

@main
struct HabitdotApp: App {
    @State private var store = HabitStore()
    @State private var purchaseStore = HabitdotPurchaseStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .environment(purchaseStore)
        }
    }
}
