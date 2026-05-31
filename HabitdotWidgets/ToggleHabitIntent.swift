import AppIntents
import WidgetKit

struct ToggleHabitIntent: AppIntent {
    static let title: LocalizedStringResource = "intent.toggle.habit"
    static let description = IntentDescription("intent.toggle.habit.description")

    @Parameter(title: "intent.habit.id")
    var habitID: String

    init() {
        habitID = ""
    }

    init(habitID: String) {
        self.habitID = habitID
    }

    func perform() async throws -> some IntentResult {
        var snapshot = HabitdotStorage.load()
        snapshot.toggleCompletion(for: habitID, dayKey: HabitDate.dayKey(Date()))
        HabitdotStorage.save(snapshot)
        for widgetKind in HabitdotWidgetKind.all {
            WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
        }
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
