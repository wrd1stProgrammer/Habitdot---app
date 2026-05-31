import SwiftUI

struct OnboardingOptionRow: View {
    let option: OnboardingOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: option.symbolName)
                    .font(.system(size: 17, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isSelected ? Color.habitdotOnboardingAccent : Color.black.opacity(0.68))
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.habitdotOnboardingAccent.opacity(0.14) : Color.black.opacity(0.045))
                    )
                    .accessibilityHidden(true)

                Text(LocalizedStringKey(option.titleKey))
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.black)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .layoutPriority(1)

                if option.id == "light" {
                    Text("onboarding.theme.recommended")
                        .font(.system(size: 10.5, weight: .bold))
                        .foregroundStyle(Color.habitdotOnboardingAccent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(Color.habitdotOnboardingAccent.opacity(0.10), in: Capsule())
                }

                Spacer(minLength: 6)

                Image(systemName: isSelected ? "checkmark.seal.fill" : "circle")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(isSelected ? Color.habitdotOnboardingAccent : Color.gray.opacity(0.35))
                    .contentTransition(.symbolEffect(.replace))
            }
            .padding(.leading, 14)
            .padding(.trailing, 16)
            .frame(minHeight: 64)
            .background {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(isSelected ? Color.habitdotOnboardingAccent.opacity(0.10) : .white)
                    .overlay {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(isSelected ? Color.habitdotOnboardingAccent.opacity(0.75) : .clear, lineWidth: 1.5)
                    }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(LocalizedStringKey(option.titleKey)))
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
