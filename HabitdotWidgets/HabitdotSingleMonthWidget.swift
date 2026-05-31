import SwiftUI
import WidgetKit

struct HabitdotSingleMonthWidget: Widget {
    let kind = HabitdotWidgetKind.singleMonth

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitdotWidgetProvider()) { entry in
            SingleMonthWidgetView(entry: entry)
        }
        .configurationDisplayName("widget.month.name")
        .description("widget.month.description")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}
