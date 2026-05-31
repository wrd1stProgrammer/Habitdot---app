import SwiftUI

struct OnboardingQuestionView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    let page: OnboardingPage
    let selectedID: String?
    let selectAction: (String) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Text(LocalizedStringKey(page.titleKey))
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.black)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 22)
                    .padding(.top, 30)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 10)
                    .animation(entryAnimation(delay: 0), value: isVisible)

                VStack(spacing: rowSpacing) {
                    ForEach(Array(page.options.enumerated()), id: \.element.id) { index, option in
                        OnboardingOptionRow(
                            option: option,
                            isSelected: selectedID == option.id,
                            action: { selectAction(option.id) }
                        )
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 18)
                        .animation(entryAnimation(delay: Double(index) * 0.055 + 0.08), value: isVisible)
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 18)
        }
        .scrollBounceBehavior(.basedOnSize)
        .onAppear(perform: reveal)
    }

    private var rowSpacing: CGFloat {
        page == .source ? 10 : 12
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
