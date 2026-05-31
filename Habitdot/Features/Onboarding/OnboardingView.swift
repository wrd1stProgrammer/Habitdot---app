import SwiftUI

struct OnboardingView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pageIndex = 0
    @State private var selections: [OnboardingPage: String] = [:]
    @State private var commonReminderTime = Self.defaultReminderDate(hour: 21, minute: 0)
    @State private var commonReminderEnabled = true
    @State private var feedbackTrigger = 0
    @State private var isPaywallPresented = false

    let onComplete: (OnboardingCompletionPayload) -> Void

    var body: some View {
        VStack(spacing: 0) {
            if currentPage.showsHeader {
                OnboardingHeaderView(
                    pageIndex: pageIndex,
                    pageCount: OnboardingPage.allCases.count,
                    canGoBack: pageIndex > 0,
                    backAction: goBack
                )
                .fixedSize(horizontal: false, vertical: true)
                .zIndex(2)
            }

            ZStack {
                currentContent
                    .id(currentPage.id)
                    .transition(pageTransition)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .layoutPriority(1)
            .clipped()
            .zIndex(0)
            .animation(reduceMotion ? .easeInOut(duration: 0.18) : .spring(response: 0.42, dampingFraction: 0.86), value: pageIndex)

            Button(buttonTitleKey, action: goForward)
                .buttonStyle(HabitdotGradientButtonStyle(
                    isEnabled: canContinue,
                    enabledColors: buttonColors,
                    height: currentPage == .intro ? 58 : 52
                ))
                .disabled(!canContinue)
                .padding(.horizontal, currentPage == .intro ? 24 : 40)
                .padding(.bottom, currentPage == .intro ? 34 : 24)
                .zIndex(2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor.ignoresSafeArea())
        .preferredColorScheme(.light)
        .fullScreenCover(isPresented: $isPaywallPresented) {
            PaywallView(
                onClose: complete,
                onStart: complete
            )
        }
        .sensoryFeedback(.selection, trigger: feedbackTrigger)
    }

    @ViewBuilder
    private var currentContent: some View {
        switch currentPage {
        case .intro:
            OnboardingIntroView()
        case .proof:
            OnboardingProofView()
        case .reminder:
            OnboardingReminderTimeView(
                reminderTime: $commonReminderTime,
                isEnabled: $commonReminderEnabled
            )
        default:
            OnboardingQuestionView(
                page: currentPage,
                selectedID: selections[currentPage],
                selectAction: select
            )
        }
    }

    private var currentPage: OnboardingPage {
        OnboardingPage.allCases[pageIndex]
    }

    private var canContinue: Bool {
        !currentPage.requiresSelection || selections[currentPage] != nil
    }

    private var pageTransition: AnyTransition {
        reduceMotion ? .opacity : .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }

    private var buttonTitleKey: LocalizedStringKey {
        if currentPage == .intro {
            return "onboarding.intro.button"
        }
        if pageIndex == OnboardingPage.allCases.count - 1 {
            return "onboarding.startButton"
        }
        return "onboarding.continue"
    }

    private var buttonColors: [Color] {
        currentPage == .intro
        ? [Color(hex: 0x1D9BF0), Color(hex: 0x2F80ED)]
        : [Color.habitdotOnboardingAccent, Color.habitdotBlue]
    }

    private var backgroundColor: Color {
        currentPage == .intro ? .white : Color.habitdotOnboardingBackground
    }

    private func select(_ id: String) {
        feedbackTrigger += 1
        selections[currentPage] = id
    }

    private func goBack() {
        guard pageIndex > 0 else { return }
        feedbackTrigger += 1
        pageIndex -= 1
    }

    private func goForward() {
        guard canContinue else { return }
        feedbackTrigger += 1
        if pageIndex == OnboardingPage.allCases.count - 1 {
            isPaywallPresented = true
        } else {
            pageIndex += 1
        }
    }

    private func complete() {
        onComplete(
            OnboardingCompletionPayload.make(
                selectedOptions: selections,
                commonReminderTime: commonReminderComponents
            )
        )
    }

    private var commonReminderComponents: DateComponents? {
        guard commonReminderEnabled else { return nil }
        return Calendar.current.dateComponents([.hour, .minute], from: commonReminderTime)
    }

    private static func defaultReminderDate(hour: Int, minute: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }
}

private extension OnboardingPage {
    var showsHeader: Bool {
        self != .intro
    }
}
