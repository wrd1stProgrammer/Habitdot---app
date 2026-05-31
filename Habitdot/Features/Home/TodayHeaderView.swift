import SwiftUI

struct TodayHeaderView: View {
    @Environment(HabitStore.self) private var store
    @State private var isMotivationExpanded = false
    @State private var collapseTask: Task<Void, Never>?
    @State private var greetingDate = Date()

    private let greetingRefreshTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(headerText)
                .font(.system(size: store.dailyMotivationText == nil ? 20 : 18, weight: .bold))
                .foregroundStyle(Color.habitdotInk)
                .lineLimit(motivationLineLimit)
                .truncationMode(.tail)
                .minimumScaleFactor(0.9)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)
                .contentShape(Rectangle())
                .onTapGesture(perform: toggleMotivationExpansion)
                .accessibilityAddTraits(hasMotivation ? [.isButton] : [])

            VStack(alignment: .trailing, spacing: 0) {
                Text(AppLocalization.monthAbbreviation(store.selectedDate))
                    .font(.system(size: 14, weight: .medium))
                Text("\(Calendar.current.component(.day, from: store.selectedDate))")
                    .font(.system(size: 25, weight: .bold))
            }
            .foregroundStyle(Color.habitdotInk)
            .fixedSize(horizontal: true, vertical: false)
        }
        .animation(.spring(response: 0.36, dampingFraction: 0.86), value: isMotivationExpanded)
        .onChange(of: store.dailyMotivationText ?? "") { _, _ in
            collapseMotivation(animated: false)
        }
        .onAppear {
            greetingDate = Date()
        }
        .onReceive(greetingRefreshTimer) { date in
            guard !hasMotivation else { return }
            greetingDate = date
        }
        .onDisappear {
            collapseTask?.cancel()
            collapseTask = nil
        }
    }

    private var headerText: String {
        store.dailyMotivationText ?? AppLocalization.localizedString(greetingKey)
    }

    private var hasMotivation: Bool {
        store.dailyMotivationText?.isEmpty == false
    }

    private var motivationLineLimit: Int? {
        guard hasMotivation else { return 2 }
        return isMotivationExpanded ? nil : 2
    }

    private var greetingKey: String {
        let hour = Calendar.current.component(.hour, from: greetingDate)
        switch hour {
        case 5..<12: return "home.greeting.morning"
        case 12..<18: return "home.greeting.afternoon"
        case 18..<22: return "home.greeting.evening"
        default: return "home.greeting.night"
        }
    }

    private func toggleMotivationExpansion() {
        guard hasMotivation else { return }

        if isMotivationExpanded {
            collapseMotivation(animated: true)
        } else {
            expandMotivation()
        }
    }

    private func expandMotivation() {
        collapseTask?.cancel()

        withAnimation(.spring(response: 0.36, dampingFraction: 0.86)) {
            isMotivationExpanded = true
        }

        collapseTask = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                collapseMotivation(animated: true)
            }
        }
    }

    private func collapseMotivation(animated: Bool) {
        collapseTask?.cancel()
        collapseTask = nil

        if animated {
            withAnimation(.spring(response: 0.36, dampingFraction: 0.86)) {
                isMotivationExpanded = false
            }
        } else {
            isMotivationExpanded = false
        }
    }
}
