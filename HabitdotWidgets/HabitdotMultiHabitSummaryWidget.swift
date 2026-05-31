import SwiftUI
import WidgetKit

struct HabitdotMultiHabitSummaryWidget: Widget {
    let kind = HabitdotWidgetKind.multiHabitSummary

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitdotWidgetProvider()) { entry in
            MultiHabitSummaryWidgetView(entry: entry)
        }
        .configurationDisplayName("widget.multi.name")
        .description("widget.multi.description")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}
