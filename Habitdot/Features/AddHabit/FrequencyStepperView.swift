import SwiftUI

struct FrequencyStepperView: View {
    @Binding var timesPerWeek: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("add.frequency")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.habitdotSecondaryText)

            HStack {
                Button("add.frequency.decrease", systemImage: "minus", action: decrease)
                    .labelStyle(.iconOnly)
                    .font(.system(size: 17, weight: .bold))
                    .frame(width: 38, height: 38)
                    .background(Color(.systemGray6), in: Circle())

                Spacer()

                Text(displayText)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.habitdotInk)

                Spacer()

                Button("add.frequency.increase", systemImage: "plus", action: increase)
                    .labelStyle(.iconOnly)
                    .font(.system(size: 17, weight: .bold))
                    .frame(width: 38, height: 38)
                    .background(Color(.systemGray6), in: Circle())
            }
            .padding(12)
            .background(Color.habitdotCard, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var displayText: String {
        timesPerWeek == 7
        ? AppLocalization.localizedString("habit.frequency.everyday")
        : String(format: AppLocalization.localizedString("habit.frequency.timesPerWeek"), timesPerWeek)
    }

    private func decrease() {
        timesPerWeek = max(1, timesPerWeek - 1)
    }

    private func increase() {
        timesPerWeek = min(7, timesPerWeek + 1)
    }
}
