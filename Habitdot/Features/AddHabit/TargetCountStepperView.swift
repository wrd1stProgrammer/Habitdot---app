import SwiftUI

struct TargetCountStepperView: View {
    @Binding var targetCount: Int

    var body: some View {
        Stepper(value: $targetCount, in: 1...10) {
            VStack(alignment: .leading, spacing: 4) {
                Text("add.target")
                    .font(.headline)
                Text(String(format: AppLocalization.localizedString("add.target.count"), targetCount))
                    .font(.subheadline)
                    .foregroundStyle(Color.habitdotSecondaryText)
            }
        }
        .padding(18)
        .background(Color.habitdotCard, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
