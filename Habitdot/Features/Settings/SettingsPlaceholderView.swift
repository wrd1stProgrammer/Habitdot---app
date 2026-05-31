import SwiftUI

struct SettingsPlaceholderView: View {
    let route: SettingsRoute

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: iconName)
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(Color.habitdotAccent)

            Text(LocalizedStringKey(route.titleKey))
                .font(.title.weight(.bold))

            Text("settings.placeholder.body")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.habitdotSecondaryText)
                .padding(.horizontal, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var iconName: String {
        switch route {
        case .privacy, .terms: "doc.text"
        case .discord, .instagram: "person.2"
        case .feedback, .contact, .bug: "envelope"
        case .review: "star"
        default: "gearshape"
        }
    }
}
