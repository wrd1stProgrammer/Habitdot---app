import SwiftUI

struct OnboardingHeaderView: View {
    let pageIndex: Int
    let pageCount: Int
    let canGoBack: Bool
    let backAction: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button("onboarding.back", systemImage: "chevron.left", action: backAction)
                .labelStyle(.iconOnly)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.black)
                .opacity(canGoBack ? 1 : 0)
                .disabled(!canGoBack)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.habitdotOnboardingTrack)
                    Capsule()
                        .fill(Color.habitdotOnboardingAccent)
                        .frame(width: proxy.size.width * progress)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, 24)
        .padding(.top, 14)
    }

    private var progress: Double {
        Double(pageIndex + 1) / Double(max(pageCount, 1))
    }
}
