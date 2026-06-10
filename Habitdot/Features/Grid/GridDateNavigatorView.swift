import SwiftUI

struct GridDateNavigatorView: View {
    @Environment(HabitStore.self) private var store

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 16) {
                Button("grid.previous", systemImage: "chevron.left", action: { step(-1) })
                    .labelStyle(.iconOnly)

                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.habitdotSecondaryText)
                    .frame(maxWidth: .infinity)
                    .contentTransition(.numericText())
                    .id(title)

                Button("grid.next", systemImage: "chevron.right", action: { step(1) })
                    .labelStyle(.iconOnly)
            }
            .offset(x: -6)
            .frame(maxWidth: .infinity)

            Button(LocalizedStringKey(toggleTitleKey), systemImage: toggleSymbolName, action: toggleDisplayMode)
                .labelStyle(.iconOnly)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.habitdotAccent)
                .frame(width: 38, height: 38)
                .background {
                    Circle()
                        .fill(Color.habitdotElevatedSurface)
                        .habitdotFloatingSurface(Circle())
                }
        }
        .font(.system(size: 19, weight: .semibold))
        .foregroundStyle(Color.habitdotSecondaryText)
        .padding(.leading, 4)
        .padding(.trailing, 2)
        .animation(.spring(response: 0.34, dampingFraction: 0.86), value: title)
    }

    private var title: String {
        switch store.gridPeriod {
        case .weekly:
            let dates = store.progressDates(for: .weekly, around: store.gridReferenceDate)
            guard let first = dates.first, let last = dates.last else { return "" }
            return "\(AppLocalization.monthDay(first)) - \(AppLocalization.monthDay(last))"
        case .monthly:
            return AppLocalization.monthYear(store.gridReferenceDate)
        case .quarterly:
            var calendar = Calendar.current
            calendar.locale = AppLocalization.selectedLocale
            calendar.firstWeekday = store.snapshot.settings.firstWeekday
            let month = calendar.component(.month, from: store.gridReferenceDate)
            let quarterStartMonth = ((month - 1) / 3) * 3 + 1
            var components = calendar.dateComponents([.year], from: store.gridReferenceDate)
            components.month = quarterStartMonth
            components.day = 1
            guard
                let start = calendar.date(from: components),
                let end = calendar.date(byAdding: .month, value: 2, to: start)
            else { return "" }
            return "\(AppLocalization.monthYear(start, abbreviated: true)) - \(AppLocalization.monthYear(end, abbreviated: true))"
        }
    }

    private func step(_ direction: Int) {
        withAnimation(.spring(response: 0.34, dampingFraction: 0.86)) {
            store.stepGridDate(direction)
        }
    }

    private var toggleSymbolName: String {
        store.gridDisplayMode == .dots ? "calendar" : "square.grid.3x3.fill"
    }

    private var toggleTitleKey: String {
        store.gridDisplayMode == .dots ? "grid.showCalendar" : "grid.showDots"
    }

    private func toggleDisplayMode() {
        store.triggerFeedback()
        store.gridDisplayMode = store.gridDisplayMode == .dots ? .calendar : .dots
    }
}
