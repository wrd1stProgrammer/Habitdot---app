import SwiftUI

struct HabitNameFieldView: View {
    @Binding var title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("add.name")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.habitdotSecondaryText)

            TextField("add.name.placeholder", text: $title)
                .font(.system(size: 18, weight: .semibold))
                .textInputAutocapitalization(.words)
                .padding(14)
                .background(Color.habitdotCard, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}
