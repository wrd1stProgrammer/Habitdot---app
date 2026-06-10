import SwiftUI

struct OnboardingFirstHabitView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var isCustomFieldFocused: Bool
    @State private var isVisible = false

    let selectedID: String?
    @Binding var customHabitTitle: String
    let selectAction: (String) -> Void
    let clearCustomSelection: () -> Void

    private var isCustomSelected: Bool {
        selectedID == OnboardingHabitSelection.customID
    }

    private var trimmedCustomHabitTitle: String {
        customHabitTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Text("onboarding.habit.title")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.black)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 22)
                    .padding(.top, 30)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 10)
                    .animation(entryAnimation(delay: 0), value: isVisible)

                VStack(spacing: 12) {
                    ForEach(Array(OnboardingPage.firstHabit.options.enumerated()), id: \.element.id) { index, option in
                        OnboardingOptionRow(
                            option: option,
                            isSelected: selectedID == option.id,
                            action: { selectAction(option.id) }
                        )
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 18)
                        .animation(entryAnimation(delay: Double(index) * 0.055 + 0.08), value: isVisible)
                    }

                    customHabitCard
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 18)
                        .animation(entryAnimation(delay: 0.36), value: isVisible)
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 18)
        }
        .scrollBounceBehavior(.basedOnSize)
        .onAppear(perform: reveal)
        .onChange(of: customHabitTitle) { _, newValue in
            handleCustomHabitTitleChange(newValue)
        }
        .onChange(of: isCustomFieldFocused) { _, isFocused in
            guard isFocused, !trimmedCustomHabitTitle.isEmpty else { return }
            selectAction(OnboardingHabitSelection.customID)
        }
    }

    private var customHabitCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "pencil.line")
                    .font(.system(size: 17, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isCustomSelected ? Color.habitdotOnboardingAccent : Color.black.opacity(0.68))
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(isCustomSelected ? Color.habitdotOnboardingAccent.opacity(0.14) : Color.black.opacity(0.045))
                    )
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 3) {
                    Text("onboarding.habit.custom.title")
                        .font(.body.bold())
                        .foregroundStyle(.black)

                    Text("onboarding.habit.custom.helper")
                        .font(.subheadline)
                        .foregroundStyle(.black.opacity(0.54))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Image(systemName: isCustomSelected ? "checkmark.seal.fill" : "circle")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(isCustomSelected ? Color.habitdotOnboardingAccent : Color.gray.opacity(0.35))
                    .contentTransition(.symbolEffect(.replace))
                    .accessibilityHidden(true)
            }

            TextField("onboarding.habit.custom.placeholder", text: $customHabitTitle)
                .textInputAutocapitalization(.sentences)
                .autocorrectionDisabled(false)
                .submitLabel(.done)
                .focused($isCustomFieldFocused)
                .font(.body.weight(.semibold))
                .foregroundStyle(.black)
                .padding(.horizontal, 16)
                .frame(minHeight: 50)
                .background(Color.black.opacity(0.045), in: RoundedRectangle(cornerRadius: 18))
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(isCustomFieldFocused || isCustomSelected ? Color.habitdotOnboardingAccent.opacity(0.65) : .clear, lineWidth: 1.4)
                }
        }
        .padding(.leading, 14)
        .padding(.trailing, 16)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 28)
                .fill(isCustomSelected ? Color.habitdotOnboardingAccent.opacity(0.10) : .white)
                .overlay {
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(isCustomSelected ? Color.habitdotOnboardingAccent.opacity(0.75) : .clear, lineWidth: 1.5)
                }
        }
        .accessibilityElement(children: .contain)
    }

    private func handleCustomHabitTitleChange(_ newValue: String) {
        let trimmedTitle = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedTitle.isEmpty {
            if isCustomSelected {
                clearCustomSelection()
            }
        } else {
            selectAction(OnboardingHabitSelection.customID)
        }
    }

    private func reveal() {
        isVisible = reduceMotion
        guard !reduceMotion else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
            isVisible = true
        }
    }

    private func entryAnimation(delay: Double) -> Animation {
        reduceMotion
        ? .easeOut(duration: 0.01)
        : .spring(response: 0.42, dampingFraction: 0.88).delay(delay)
    }
}
