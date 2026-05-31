import SwiftUI
import StoreKit

struct SettingsSheetView: View {
    @Environment(HabitStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.requestReview) private var requestReview
    @State private var feedbackKind: SettingsFeedbackKind?
    var proAction: () -> Void = {}

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    HStack {
                        Spacer()
                        Button("settings.close", systemImage: "xmark", action: { dismiss() })
                            .labelStyle(.iconOnly)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.habitdotInk)
                            .frame(width: 44, height: 44)
                            .background(Color.habitdotCard, in: Circle())
                    }

                    Text("settings.title")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(Color.habitdotInk)

                    if !store.isProUnlocked {
                        SettingsUpgradeCardView(action: proAction)
                    }

                    SettingsSectionView(
                        titleKey: "settings.section.app",
                        routes: [.appearance, .language, .weekStart, .reminders, .reorder]
                    )

                    SettingsActionSectionView(
                        titleKey: "settings.section.support",
                        items: supportItems
                    )

                    SettingsSectionView(
                        titleKey: "settings.section.legal",
                        routes: [.privacy, .terms]
                    )

                    Text("settings.version")
                        .font(.footnote)
                        .foregroundStyle(Color.habitdotSecondaryText)
                        .padding(.bottom, 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 22)
            }
            .background(Color.habitdotBackground.ignoresSafeArea())
            .navigationDestination(for: SettingsRoute.self) { route in
                SettingsDestinationView(route: route)
            }
            .sheet(item: $feedbackKind) { kind in
                FeedbackComposeView(kind: kind)
                    .presentationDetents([.medium, .large])
                    .presentationCornerRadius(28)
            }
        }
    }

    private var supportItems: [SettingsActionItem] {
        [
            SettingsActionItem(
                id: SettingsRoute.widgetGuide.id,
                titleKey: SettingsRoute.widgetGuide.titleKey,
                trailingSymbolName: "arrow.up.forward",
                action: openWidgetGuide
            ),
            SettingsActionItem(
                id: SettingsRoute.feedback.id,
                titleKey: SettingsRoute.feedback.titleKey,
                trailingSymbolName: "chevron.right",
                action: { feedbackKind = .feedback }
            ),
            SettingsActionItem(
                id: SettingsRoute.contact.id,
                titleKey: SettingsRoute.contact.titleKey,
                trailingSymbolName: "chevron.right",
                action: { feedbackKind = .contact }
            ),
            SettingsActionItem(
                id: SettingsRoute.bug.id,
                titleKey: SettingsRoute.bug.titleKey,
                trailingSymbolName: "chevron.right",
                action: { feedbackKind = .bug }
            ),
            SettingsActionItem(
                id: SettingsRoute.review.id,
                titleKey: SettingsRoute.review.titleKey,
                trailingSymbolName: "star",
                action: { requestReview() }
            )
        ]
    }

    private func openWidgetGuide() {
        guard let url = URL(string: "https://support.apple.com/guide/iphone/add-edit-and-remove-widgets-iphb8f1bf206/ios") else { return }
        openURL(url)
    }
}
