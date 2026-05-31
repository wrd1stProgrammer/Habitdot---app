import SwiftUI

struct ShellHeaderActionsView: View {
    let isProUnlocked: Bool
    let isLoadingPro: Bool
    let proAction: () -> Void
    let settingsAction: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            Button(action: handleProTap) {
                HStack(spacing: 8) {
                    if isLoadingPro {
                        ProgressView()
                            .scaleEffect(0.76)
                            .tint(Color.habitdotInk)
                    } else {
                        Image(systemName: isProUnlocked ? "checkmark.seal.fill" : "star.fill")
                    }

                    Text(isProUnlocked ? "home.proActive" : "home.getPro")
                }
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(isProUnlocked ? Color(hex: 0x1D6DFF) : Color.habitdotInk)
                .padding(.horizontal, 14)
                .frame(height: 40)
            }
            .buttonStyle(.plain)
            .habitdotFloatingSurface(Capsule())
            .disabled(isLoadingPro)

            Spacer()

            Button(action: settingsAction) {
                Image(systemName: "gearshape")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(Color.habitdotInk)
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .habitdotFloatingSurface(Circle())
            .accessibilityLabel(Text("settings.title"))
        }
    }

    private func handleProTap() {
        guard !isProUnlocked, !isLoadingPro else { return }
        proAction()
    }
}
