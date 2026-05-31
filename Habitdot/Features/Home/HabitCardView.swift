import SwiftUI

struct HabitCardView: View {
    @Environment(HabitStore.self) private var store
    @State private var isPurposeExpanded = false
    @State private var purposeCollapseTask: Task<Void, Never>?

    let habit: Habit
    let editAction: () -> Void

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
                            .lineLimit(isPurposeExpanded ? nil : 1)
                            .truncationMode(.tail)
                            .fixedSize(horizontal: false, vertical: true)
                            .contentShape(Rectangle())
                            .onTapGesture(perform: togglePurposeExpansion)
                            .accessibilityAddTraits(.isButton)
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

                Button(action: {
                    store.triggerFeedback()
                    editAction()
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.habitdotInk)
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("habit.more"))
            }

            HStack(spacing: 12) {
                HabitProgressDotRowView(habit: habit)

                Spacer(minLength: 10)

                Button(action: { store.toggle(habit, on: store.selectedDate) }) {
                    Image(systemName: isComplete ? "checkmark" : "plus.circle")
                        .font(.system(size: isComplete ? 23 : 27, weight: .bold))
                        .foregroundStyle(isComplete ? Color.habitdotInk : Color.habitdotInk)
                        .contentTransition(.symbolEffect(.replace))
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(isComplete ? "habit.markIncomplete" : "habit.markComplete"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(minHeight: visiblePurpose == nil ? 92 : 104, alignment: .top)
        .habitdotCard()
        .contentShape(RoundedRectangle(cornerRadius: 19, style: .continuous))
        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 19, style: .continuous))
        .animation(.spring(response: 0.32, dampingFraction: 0.78), value: isComplete)
        .animation(.spring(response: 0.34, dampingFraction: 0.86), value: isPurposeExpanded)
        .onChange(of: visiblePurpose ?? "") { _, _ in
            collapsePurpose(animated: false)
        }
        .onDisappear {
            purposeCollapseTask?.cancel()
            purposeCollapseTask = nil
        }
    }

    private var isComplete: Bool {
        store.isComplete(habit, on: store.selectedDate)
    }

    private var streak: Int {
        store.streak(for: habit, endingAt: store.selectedDate)
    }

    private var visiblePurpose: String? {
        let trimmed = habit.purpose?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == false ? trimmed : nil
    }

    private func togglePurposeExpansion() {
        guard visiblePurpose != nil else { return }

        if isPurposeExpanded {
            collapsePurpose(animated: true)
        } else {
            expandPurpose()
        }
    }

    private func expandPurpose() {
        purposeCollapseTask?.cancel()

        withAnimation(.spring(response: 0.34, dampingFraction: 0.86)) {
            isPurposeExpanded = true
        }

        purposeCollapseTask = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                collapsePurpose(animated: true)
            }
        }
    }

    private func collapsePurpose(animated: Bool) {
        purposeCollapseTask?.cancel()
        purposeCollapseTask = nil

        if animated {
            withAnimation(.spring(response: 0.34, dampingFraction: 0.86)) {
                isPurposeExpanded = false
            }
        } else {
            isPurposeExpanded = false
        }
    }
}
