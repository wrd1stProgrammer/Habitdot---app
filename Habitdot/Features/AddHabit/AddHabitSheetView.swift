import SwiftUI
import StoreKit

struct AddHabitSheetView: View {
    @Environment(HabitStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview

    let editingHabit: Habit?
    var proAction: () -> Void

    @State private var title = ""
    @State private var purpose = ""
    @State private var colorToken: HabitColorToken = .amber
    @State private var timesPerWeek = 7
    @State private var reminderEnabled = false
    @State private var reminderTime = Self.defaultReminderDate(hour: 9, minute: 0)

    init(editingHabit: Habit? = nil, proAction: @escaping () -> Void = {}) {
        self.editingHabit = editingHabit
        self.proAction = proAction
        _title = State(initialValue: editingHabit?.title ?? "")
        _purpose = State(initialValue: editingHabit?.purpose ?? "")
        _colorToken = State(initialValue: editingHabit?.colorToken ?? .amber)
        _timesPerWeek = State(initialValue: editingHabit?.frequency.timesPerWeekValue ?? 7)
        _reminderEnabled = State(initialValue: editingHabit?.reminderHour != nil)
        _reminderTime = State(initialValue: Self.defaultReminderDate(
            hour: editingHabit?.reminderHour ?? 9,
            minute: editingHabit?.reminderMinute ?? 0
        ))
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    HabitNameFieldView(title: $title)
                    if store.isProUnlocked {
                        HabitPurposeFieldView(purpose: $purpose)
                    } else {
                        AddHabitProLockedRowView(
                            titleKey: "add.purpose",
                            subtitleKey: "add.purpose.proLocked",
                            action: proAction
                        )
                    }
                    AddHabitSuggestionRowView(selectAction: { title = $0 })
                    AddHabitColorPickerView(
                        selectedColor: $colorToken,
                        isProUnlocked: store.isProUnlocked,
                        proAction: proAction
                    )
                    FrequencyStepperView(timesPerWeek: $timesPerWeek)
                    ReminderToggleRowView(isOn: $reminderEnabled, time: $reminderTime)
                }
                .padding(16)
            }
            .navigationTitle("add.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("add.cancel", action: { dismiss() })
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("add.done", action: save)
                        .fontWeight(.semibold)
                        .disabled(!canSave)
                }
            }
        }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func save() {
        guard editingHabit != nil || store.canCreateHabit else {
            proAction()
            return
        }

        let shouldRequestReviewAfterSave = editingHabit == nil
            && store.activeHabits.isEmpty
            && !HabitReviewPromptTracker.didPromptAfterFirstHabit
        let frequency: HabitFrequency = timesPerWeek == 7 ? .everyday : .timesPerWeek(timesPerWeek)
        let savedPurpose = store.isProUnlocked ? purpose : editingHabit?.purpose
        let savedColorToken = store.isProUnlocked || colorToken.isFreeIncluded ? colorToken : editingHabit?.colorToken ?? .amber
        let reminderComponents = reminderEnabled ? Calendar.current.dateComponents([.hour, .minute], from: reminderTime) : nil

        if let editingHabit {
            store.updateHabitDetails(
                editingHabit,
                title: title,
                purpose: savedPurpose,
                colorToken: savedColorToken,
                frequency: frequency,
                reminderHour: reminderComponents?.hour,
                reminderMinute: reminderComponents?.minute,
                targetCount: editingHabit.targetCount
            )
        } else {
            store.addHabit(
                title: title,
                purpose: savedPurpose,
                colorToken: savedColorToken,
                frequency: frequency,
                reminderHour: reminderComponents?.hour,
                reminderMinute: reminderComponents?.minute,
                targetCount: 1
            )
        }
        store.triggerFeedback()
        dismiss()

        if shouldRequestReviewAfterSave {
            HabitReviewPromptTracker.markPromptedAfterFirstHabit()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                requestReview()
            }
        }
    }

    private static func defaultReminderDate(hour: Int, minute: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }
}

private extension HabitFrequency {
    var timesPerWeekValue: Int {
        switch self {
        case .everyday:
            7
        case .timesPerWeek(let count):
            count
        }
    }
}

private struct AddHabitProLockedRowView: View {
    let titleKey: String
    let subtitleKey: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(hex: 0x1D6DFF))
                    .frame(width: 28, height: 28)
                    .background(Color(hex: 0x1D6DFF).opacity(0.12), in: Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(LocalizedStringKey(titleKey))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.habitdotSecondaryText)

                    Text(LocalizedStringKey(subtitleKey))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.habitdotInk)
                        .lineLimit(1)
                        .minimumScaleFactor(0.86)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.habitdotTertiaryText)
            }
            .padding(14)
            .background(Color.habitdotCard, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
