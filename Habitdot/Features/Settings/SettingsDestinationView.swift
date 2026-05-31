import SwiftUI

struct SettingsDestinationView: View {
    let route: SettingsRoute

    var body: some View {
        Group {
            switch route {
            case .appearance:
                AppearanceSettingsView()
            case .language:
                LanguageSettingsView()
            case .weekStart:
                WeekStartSettingsView()
            case .reminders:
                UpcomingRemindersView()
            case .reorder:
                ReorderHabitsView()
            case .archived:
                ArchivedHabitsView()
            case .importExport:
                ImportExportHabitsView()
            case .widgetGuide:
                WidgetGuideView()
            case .privacy:
                LegalDocumentView(document: .privacyPolicy)
            case .terms:
                LegalDocumentView(document: .termsOfUse)
            default:
                SettingsPlaceholderView(route: route)
            }
        }
        .navigationTitle(LocalizedStringKey(route.titleKey))
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.habitdotBackground.ignoresSafeArea())
    }
}
