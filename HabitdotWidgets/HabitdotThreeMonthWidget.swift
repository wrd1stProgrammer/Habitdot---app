import SwiftUI
import WidgetKit

struct HabitdotThreeMonthWidget: Widget {
    let kind = HabitdotWidgetKind.threeMonth

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitdotWidgetProvider()) { entry in
            ThreeMonthWidgetView(entry: entry)
        }
        .configurationDisplayName("widget.threeMonth.name")
        .description("widget.threeMonth.description")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}
