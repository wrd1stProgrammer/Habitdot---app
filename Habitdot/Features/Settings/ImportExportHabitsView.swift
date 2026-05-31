import SwiftUI

struct ImportExportHabitsView: View {
    @Environment(HabitStore.self) private var store
    @State private var importText = ""
    @State private var importSucceeded: Bool?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("settings.importExport.export")
                    .font(.headline)
                    .foregroundStyle(Color.habitdotSecondaryText)

                ScrollView(.horizontal) {
                    Text(store.exportJSON())
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(Color.habitdotInk)
                        .padding(14)
                }
                .frame(maxWidth: .infinity, minHeight: 160, alignment: .leading)
                .habitdotCard()

                Text("settings.importExport.import")
                    .font(.headline)
                    .foregroundStyle(Color.habitdotSecondaryText)

                TextField("settings.importExport.placeholder", text: $importText, axis: .vertical)
                    .lineLimit(6...)
                    .font(.system(.callout, design: .monospaced))
                    .padding(14)
                    .habitdotCard()

                Button("settings.importExport.button", action: importSnapshot)
                    .buttonStyle(HabitdotGradientButtonStyle(isEnabled: !importText.isEmpty))
                    .disabled(importText.isEmpty)

                if let importSucceeded {
                    Text(importSucceeded ? "settings.importExport.success" : "settings.importExport.failure")
                        .font(.headline)
                        .foregroundStyle(importSucceeded ? Color.green : Color.habitdotAccent)
                }
            }
            .padding(16)
        }
    }

    private func importSnapshot() {
        importSucceeded = store.importJSON(importText)
    }
}
