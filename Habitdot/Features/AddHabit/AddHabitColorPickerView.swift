import SwiftUI

struct AddHabitColorPickerView: View {
    @Binding var selectedColor: HabitColorToken
    let isProUnlocked: Bool
    let proAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("add.color")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.habitdotSecondaryText)

            LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                ForEach(HabitColorToken.allCases) { token in
                    let isLocked = !isProUnlocked && !token.isFreeIncluded

                    Button(action: { select(token, isLocked: isLocked) }) {
                        ZStack {
                            Circle()
                                .fill(token.color.opacity(isLocked ? 0.34 : 1))
                                .frame(width: 21, height: 21)
                                .overlay {
                                    if selectedColor == token {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 9.5, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                }
                                .overlay {
                                    Circle()
                                        .stroke(Color.habitdotInk.opacity(selectedColor == token ? 0.18 : 0), lineWidth: 3)
                                }

                            if isLocked {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 7.5, weight: .bold))
                                    .foregroundStyle(Color.habitdotInk.opacity(0.62))
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text("add.color.option"))
                    .accessibilityAddTraits(selectedColor == token ? [.isSelected] : [])
                }
            }
        }
    }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(minimum: 20, maximum: 24), spacing: 7), count: 12)
    }

    private func select(_ token: HabitColorToken, isLocked: Bool) {
        if isLocked {
            proAction()
        } else {
            selectedColor = token
        }
    }
}
