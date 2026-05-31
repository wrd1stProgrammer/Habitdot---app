import SwiftUI

struct OnboardingIntroView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isRevealed = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 104)

            Text("onboarding.intro.title")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(Color.habitdotInk)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .minimumScaleFactor(0.82)
                .padding(.horizontal, 18)

            OnboardingIntroDotMatrix(isRevealed: isRevealed, reduceMotion: reduceMotion)
                .frame(height: 132)
                .padding(.top, 58)
                .padding(.horizontal, 20)

            Spacer(minLength: 36)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            ZStack {
                Color.white

                RadialGradient(
                    colors: [
                        Color(hex: 0x1D9BF0).opacity(0.16),
                        .clear
                    ],
                    center: .center,
                    startRadius: 20,
                    endRadius: 260
                )
                .offset(y: 70)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
        .onAppear(perform: revealDots)
    }

    private func revealDots() {
        isRevealed = reduceMotion
        guard !reduceMotion else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.84)) {
                isRevealed = true
            }
        }
    }
}

private struct OnboardingIntroDotMatrix: View {
    let isRevealed: Bool
    let reduceMotion: Bool

    private let rows = 7
    private let columns = 22
    private let spacing: CGFloat = 7

    var body: some View {
        GeometryReader { proxy in
            let cellSize = max(6, (proxy.size.width - CGFloat(columns - 1) * spacing) / CGFloat(columns))

            VStack(spacing: spacing) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<columns, id: \.self) { column in
                            dot(row: row, column: column, size: cellSize)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    private func dot(row: Int, column: Int, size: CGFloat) -> some View {
        let active = isActive(row: row, column: column)
        let delay = reduceMotion ? 0 : Double(row + column) * 0.032
        let revealedActive = isRevealed && active

        return RoundedRectangle(cornerRadius: max(3, size * 0.24), style: .continuous)
            .fill(Color(hex: 0xDDEBFA).opacity(0.78))
            .frame(width: size, height: size)
            .overlay {
                RoundedRectangle(cornerRadius: max(3, size * 0.24), style: .continuous)
                    .fill(activeColor(row: row, column: column))
                    .opacity(revealedActive ? 1 : 0)
                    .scaleEffect(revealedActive ? 1 : 0.54)
            }
            .shadow(
                color: Color(hex: 0x1D9BF0).opacity(revealedActive ? 0.18 : 0),
                radius: 5,
                y: 2
            )
            .animation(.spring(response: 0.62, dampingFraction: 0.80).delay(delay), value: isRevealed)
    }

    private func activeColor(row: Int, column: Int) -> Color {
        let columnStrength = Double(column) / Double(max(columns - 1, 1))
        let rowPulse = Double((row * 9 + column * 5) % 5) * 0.035
        let strength = min(0.92, 0.42 + columnStrength * 0.34 + rowPulse)
        return Color(
            red: 0.10 + strength * 0.10,
            green: 0.42 + strength * 0.24,
            blue: 0.82 + strength * 0.16
        )
    }

    private func isActive(row: Int, column: Int) -> Bool {
        let bias = 17 + column * 3 + max(0, column - 11) * 4
        let wave = abs(row - ((column / 3 + 2) % rows)) <= 2 ? 18 : 0
        let seed = (row * 31 + column * 17 + row * column * 7) % 100
        return seed < min(84, bias + wave)
    }
}
