import SwiftUI

struct OnboardingReminderTimeView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding var reminderTime: Date
    @Binding var isEnabled: Bool
    @State private var isVisible = false

    var body: some View {
        VStack(spacing: 24) {
            Text("onboarding.reminder.title")
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.black)
                .padding(.horizontal, 22)
                .padding(.top, 30)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 10)
                .animation(entryAnimation(delay: 0), value: isVisible)

            VStack(spacing: 16) {
                Toggle(isOn: $isEnabled.animation(.spring(response: 0.34, dampingFraction: 0.86))) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("onboarding.reminder.daily")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.black)

                        Text("onboarding.reminder.dailySubtitle")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.black.opacity(0.48))
                    }
                }
                .tint(Color.habitdotOnboardingAccent)
                .padding(.horizontal, 18)
                .frame(minHeight: 74)
                .background(.white, in: RoundedRectangle(cornerRadius: 28, style: .continuous))

                if isEnabled {
                    DatePicker("onboarding.reminder.time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                        .frame(height: 154)
                        .padding(.horizontal, 8)
                        .background(.white, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(.horizontal, 24)
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 18)
            .animation(entryAnimation(delay: 0.08), value: isVisible)
            .animation(.spring(response: 0.36, dampingFraction: 0.86), value: isEnabled)
        }
        .onAppear(perform: reveal)
        .task(id: isEnabled) {
            guard isEnabled else { return }
            await HabitReminderScheduler.requestAuthorizationIfNeeded()
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
