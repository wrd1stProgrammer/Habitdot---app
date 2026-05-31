import SwiftUI
import WidgetKit

struct HabitdotTodayChecklistWidget: Widget {
    let kind = HabitdotWidgetKind.todayChecklist

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitdotWidgetProvider()) { entry in
            TodayChecklistWidgetView(entry: entry)
        }
        .configurationDisplayName("widget.today.name")
        .description("widget.today.description")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}
