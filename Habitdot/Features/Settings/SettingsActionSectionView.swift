import SwiftUI

struct SettingsActionSectionView: View {
    let titleKey: String
    let items: [SettingsActionItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizedStringKey(titleKey))
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.habitdotSecondaryText)

            VStack(spacing: 0) {
                ForEach(items) { item in
                    Button(action: item.action) {
                        HStack {
                            Text(LocalizedStringKey(item.titleKey))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color.habitdotInk)
                            Spacer()
                            Image(systemName: item.trailingSymbolName)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.habitdotSecondaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .padding(.horizontal, 16)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if item.id != items.last?.id {
                        Divider()
                            .padding(.leading, 16)
                    }
                }
            }
            .habitdotCard()
        }
    }
}

struct SettingsActionItem: Identifiable {
    let id: String
    let titleKey: String
    let trailingSymbolName: String
    let action: () -> Void
}
