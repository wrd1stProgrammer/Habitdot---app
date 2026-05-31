import SwiftUI

struct OnboardingProofView: View {
    var body: some View {
        VStack(spacing: 26) {
            Text("onboarding.proof.title")
                .font(.system(size: 31, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.black)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 28)
                .padding(.top, 34)

            OnboardingCurveView()
                .frame(height: 340)
                .padding(.horizontal, 18)

            Text("onboarding.proof.subtitle")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(.black.opacity(0.78))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 30)

            Spacer()
        }
    }
}
