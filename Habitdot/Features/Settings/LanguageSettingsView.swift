import SwiftUI

struct LanguageSettingsView: View {
    @AppStorage(AppLanguage.storageKey) private var selectedLanguageRawValue = AppLanguage.englishUS.rawValue

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("settings.language.section")
                .font(.headline)
                .foregroundStyle(Color.habitdotSecondaryText)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                ForEach(AppLanguage.allCases) { language in
                    SettingsSelectableRowView(
                        title: language.titleKey,
                        isSelected: selectedLanguage == language,
                        action: { selectedLanguageRawValue = language.rawValue }
                    )
                    if language.id != AppLanguage.allCases.last?.id {
                        Divider().padding(.leading, 20)
                    }
                }
            }
            .habitdotCard()

            Text("settings.language.footer")
                .font(.footnote)
                .foregroundStyle(Color.habitdotSecondaryText)
                .padding(.horizontal, 4)

            Spacer()
        }
        .padding(16)
    }

    private var selectedLanguage: AppLanguage {
        AppLanguage.selected(from: selectedLanguageRawValue)
    }
}
