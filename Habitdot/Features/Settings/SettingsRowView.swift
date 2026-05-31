import SwiftUI

struct SettingsRowView: View {
    let route: SettingsRoute
    let showsDivider: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(LocalizedStringKey(route.titleKey))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.habitdotInk)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.habitdotSecondaryText)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())

            if showsDivider {
                Divider()
                    .padding(.leading, 16)
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
}
