import SwiftUI

struct SettingsSectionView: View {
    let titleKey: String
    let routes: [SettingsRoute]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizedStringKey(titleKey))
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.habitdotSecondaryText)

            VStack(spacing: 0) {
                ForEach(routes) { route in
                    NavigationLink(value: route) {
                        SettingsRowView(route: route, showsDivider: route != routes.last)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                }
            }
            .habitdotCard()
        }
    }
}
