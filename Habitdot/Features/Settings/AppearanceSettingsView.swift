import SwiftUI

struct AppearanceSettingsView: View {
    @Environment(HabitStore.self) private var store

    var body: some View {
        VStack(spacing: 18) {
            ForEach(HabitAppearance.allCases) { appearance in
                Button(action: { store.setAppearance(appearance) }) {
                    HStack {
                        Text(HabitdotDisplayText.appearanceTitle(appearance))
                            .font(.title3)
                            .foregroundStyle(Color.habitdotInk)
                        Spacer()
                        if store.snapshot.settings.appearance == appearance {
                            Image(systemName: "checkmark")
                                .font(.headline.weight(.bold))
                            .foregroundStyle(.blue)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .contentShape(Rectangle())
                    .habitdotCard()
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(16)
    }
}
