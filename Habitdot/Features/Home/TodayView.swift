import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct TodayView: View {
    @Environment(HabitStore.self) private var store
    @State private var draggedHabit: Habit?
    let editHabitAction: (Habit) -> Void

    var body: some View {
        GeometryReader { geometry in
            let cardWidth = max(geometry.size.width - 32, 0)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 8) {
                    TodayHeaderView()

                    WeekDateStripView()

                    if !store.accessibleActiveHabits.isEmpty {
                        LazyVStack(spacing: 10) {
                            ForEach(store.accessibleActiveHabits) { habit in
                                HabitCardView(
                                    habit: habit,
                                    editAction: { editHabitAction(habit) }
                                )
                                .onDrag {
                                    draggedHabit = habit
                                    store.triggerFeedback()
                                    return NSItemProvider(object: habit.id as NSString)
                                } preview: {
                                    dragPreview(for: habit, width: cardWidth)
                                }
                                .onDrop(
                                    of: [UTType.text],
                                    delegate: HabitReorderDropDelegate(
                                        targetHabit: habit,
                                        draggedHabit: $draggedHabit,
                                        store: store
                                    )
                                )
                            }
                        }
                        .padding(.top, 10)
                        .onDrop(
                            of: [UTType.text],
                            delegate: HabitReorderResetDropDelegate(draggedHabit: $draggedHabit)
                        )

                        Text("home.reorderHint")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.habitdotSecondaryText.opacity(0.72))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 6)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 64)
                .padding(.bottom, 120)
            }
        }
        .task(id: store.dailyMotivationRefreshToken) {
            await store.refreshDailyMotivationIfNeeded()
        }
    }

    private func dragPreview(for habit: Habit, width: CGFloat) -> some View {
        var calendar = Calendar.current
        calendar.firstWeekday = store.snapshot.settings.firstWeekday
        let dates = HabitDate.daysInWeek(containing: store.selectedDate, calendar: calendar)
        let completedDayKeys = Set(dates.filter { store.isComplete(habit, on: $0) }.map { HabitDate.dayKey($0) })

        return HabitCardDragPreviewView(
            habit: habit,
            dates: dates,
            completedDayKeys: completedDayKeys,
            isComplete: store.isComplete(habit, on: store.selectedDate),
            streak: store.streak(for: habit, endingAt: store.selectedDate),
            width: width
        )
    }
}

private struct HabitReorderDropDelegate: DropDelegate {
    let targetHabit: Habit
    @Binding var draggedHabit: Habit?
    let store: HabitStore

    func dropEntered(info: DropInfo) {
        guard let draggedHabit, draggedHabit.id != targetHabit.id else { return }
        withAnimation(.spring(response: 0.28, dampingFraction: 0.84)) {
            store.moveHabit(draggedHabit, to: targetHabit)
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        withAnimation(.spring(response: 0.22, dampingFraction: 0.9)) {
            draggedHabit = nil
        }
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}

private struct HabitReorderResetDropDelegate: DropDelegate {
    @Binding var draggedHabit: Habit?

    func performDrop(info: DropInfo) -> Bool {
        draggedHabit = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}

private struct HabitCardDragPreviewView: View {
    let habit: Habit
    let dates: [Date]
    let completedDayKeys: Set<String>
    let isComplete: Bool
    let streak: Int
    let width: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(habit.title)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.habitdotInk)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    if let purpose = visiblePurpose {
                        Text(purpose)
                            .font(.system(size: 11.5, weight: .semibold))
                            .foregroundStyle(Color.habitdotSecondaryText.opacity(0.72))
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                .layoutPriority(1)

                Spacer()

                HStack(spacing: 5) {
                    if streak > 0 {
                        Text("\(streak)")
                            .font(.system(size: 14, weight: .semibold))
                        Image(systemName: "flame")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    Text(HabitdotDisplayText.frequency(habit.frequency))
                        .font(.system(size: 15, weight: .medium))
                        .lineLimit(1)
                }
                .foregroundStyle(Color.habitdotSecondaryText)
                .fixedSize(horizontal: true, vertical: false)
                .layoutPriority(2)

                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.habitdotInk)
                    .frame(width: 26, height: 26)
            }

            HStack(spacing: 12) {
                HStack(spacing: 14) {
                    ForEach(dates, id: \.self) { date in
                        HabitProgressDotView(
                            color: habit.colorToken.color,
                            isComplete: completedDayKeys.contains(HabitDate.dayKey(date)),
                            isFuture: date > Date()
                        )
                    }
                }

                Spacer(minLength: 10)

                Image(systemName: isComplete ? "checkmark" : "plus.circle")
                    .font(.system(size: isComplete ? 23 : 27, weight: .bold))
                    .foregroundStyle(Color.habitdotInk)
                    .frame(width: 34, height: 34)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(width: width, height: visiblePurpose == nil ? 92 : 104)
        .habitdotCard()
        .clipShape(RoundedRectangle(cornerRadius: 19, style: .continuous))
        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 19, style: .continuous))
    }

    private var visiblePurpose: String? {
        let trimmed = habit.purpose?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == false ? trimmed : nil
    }
}
