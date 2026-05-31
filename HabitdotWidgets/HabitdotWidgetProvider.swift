import WidgetKit

struct HabitdotWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> HabitdotWidgetEntry {
        HabitdotWidgetEntry(date: Date(), snapshot: WidgetSampleData.snapshot)
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitdotWidgetEntry) -> Void) {
        let snapshot = HabitdotStorage.load()
        completion(HabitdotWidgetEntry(date: Date(), snapshot: snapshot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitdotWidgetEntry>) -> Void) {
        let snapshot = HabitdotStorage.load()
        let entry = HabitdotWidgetEntry(date: Date(), snapshot: snapshot)
        completion(Timeline(entries: [entry], policy: .after(nextMidnight())))
    }

    private func nextMidnight() -> Date {
        Calendar.current.nextDate(after: Date(), matching: DateComponents(hour: 0, minute: 1), matchingPolicy: .nextTime) ?? Date().addingTimeInterval(3600)
    }
}
