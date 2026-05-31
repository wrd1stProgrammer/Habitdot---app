import WidgetKit
import SwiftUI

@main
struct HabitdotWidgetsBundle: WidgetBundle {
    var body: some Widget {
        HabitdotTodayChecklistWidget()
        HabitdotSingleMonthWidget()
        HabitdotThreeMonthWidget()
        HabitdotMultiHabitSummaryWidget()
    }
}
