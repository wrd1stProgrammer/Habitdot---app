import SwiftUI

struct WeekDateCellView: View {
    let date: Date
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(isSelected ? Color.habitdotInk : .clear)
                .frame(width: 5, height: 5)

            Text(weekdayLabel)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(isSelected ? Color.habitdotSecondaryText : Color.habitdotTertiaryText)

            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(isSelected ? Color.habitdotInk : Color.habitdotSecondaryText)
        }
        .frame(width: 36, height: 70)
        .background {
            if isSelected {
                Capsule()
                    .fill(Color.habitdotCard)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AppLocalization.fullDate(date))
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private var weekdayLabel: String {
        String(AppLocalization.weekdayAbbreviation(date).uppercased().replacingOccurrences(of: ".", with: "").prefix(2))
    }
}
