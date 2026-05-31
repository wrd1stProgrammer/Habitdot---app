import SwiftUI
import WidgetKit

struct ProWidgetLockView: View {
    let titleKey: LocalizedStringKey
    let bodyKey: LocalizedStringKey

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black.opacity(0.10),
                    Color.habitdotBlue.opacity(0.18),
                    Color.black.opacity(0.24)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(Color.black.opacity(0.72))
                    .frame(width: 40, height: 40)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.50, green: 0.84, blue: 1.0), Color.habitdotBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: Circle()
                    )
                    .shadow(color: Color.habitdotBlue.opacity(0.32), radius: 12, x: 0, y: 5)

                Text(titleKey)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(bodyKey)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.82))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.76)
            }
            .padding(.horizontal, 18)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
