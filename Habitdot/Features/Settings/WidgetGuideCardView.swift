import SwiftUI

struct WidgetGuideCardView: View {
    let symbolName: String
    let titleKey: String
    let bodyKey: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: symbolName)
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.habitdotAccent)
                .frame(width: 42, height: 42)
                .background(Color.habitdotAccent.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizedStringKey(titleKey))
                    .font(.headline)
                    .foregroundStyle(Color.habitdotInk)
                Text(LocalizedStringKey(bodyKey))
                    .font(.callout)
                    .foregroundStyle(Color.habitdotSecondaryText)
            }
        }
        .padding(18)
        .habitdotCard()
    }
}
