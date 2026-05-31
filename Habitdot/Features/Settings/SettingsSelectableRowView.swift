import SwiftUI

struct SettingsSelectableRowView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(LocalizedStringKey(title))
                    .font(.title3)
                    .foregroundStyle(Color.habitdotInk)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.blue)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .padding(.horizontal, 20)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
