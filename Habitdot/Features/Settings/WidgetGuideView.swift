import SwiftUI

struct WidgetGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                WidgetGuideCardView(
                    symbolName: "checkmark.circle.fill",
                    titleKey: "settings.widgetGuide.small.title",
                    bodyKey: "settings.widgetGuide.small.body"
                )
                WidgetGuideCardView(
                    symbolName: "circle.grid.3x3.fill",
                    titleKey: "settings.widgetGuide.grid.title",
                    bodyKey: "settings.widgetGuide.grid.body"
                )
                WidgetGuideCardView(
                    symbolName: "sparkles",
                    titleKey: "settings.widgetGuide.pro.title",
                    bodyKey: "settings.widgetGuide.pro.body"
                )
            }
            .padding(16)
        }
    }
}
