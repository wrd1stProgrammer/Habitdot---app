import SwiftUI

struct AddHabitSuggestionRowView: View {
    let selectAction: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("add.suggestions")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.habitdotSecondaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(suggestions, id: \.self) { key in
                        Button(action: { selectAction(AppLocalization.localizedString(key)) }) {
                            Text(LocalizedStringKey(key))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.habitdotInk)
                                .padding(.horizontal, 14)
                                .frame(height: 38)
                                .background(Color.habitdotCard, in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var suggestions: [String] {
        [
            "habit.seed.walk",
            "habit.seed.water",
            "habit.seed.read",
            "habit.seed.exercise",
            "habit.seed.sleep"
        ]
    }
}
