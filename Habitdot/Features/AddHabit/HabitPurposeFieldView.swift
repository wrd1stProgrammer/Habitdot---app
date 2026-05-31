import SwiftUI

struct HabitPurposeFieldView: View {
    @Binding var purpose: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text("add.purpose")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.habitdotSecondaryText)

                Text("add.optional")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.habitdotSecondaryText.opacity(0.72))
            }

            TextField("add.purpose.placeholder", text: $purpose, axis: .vertical)
                .font(.system(size: 16, weight: .semibold))
                .textInputAutocapitalization(.sentences)
                .lineLimit(1...2)
                .padding(14)
                .background(Color.habitdotCard, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .onChange(of: purpose) { _, newValue in
                    guard newValue.count > 160 else { return }
                    purpose = String(newValue.prefix(160))
                }
        }
    }
}
