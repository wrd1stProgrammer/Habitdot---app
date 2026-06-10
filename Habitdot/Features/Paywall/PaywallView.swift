import SwiftUI

struct PaywallView: View {
    @Environment(HabitStore.self) private var store
    @Environment(HabitdotPurchaseStore.self) private var purchaseStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedPlan = HabitdotProPlan.defaultPlan
    @State private var didAppear = false
    @State private var didRecordPaywallView = false
    @State private var isErrorPresented = false
    @State private var errorMessage = ""

    let onClose: () -> Void
    let onStart: () -> Void

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ZStack(alignment: .top) {
                    PaywallBackgroundView()

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            hero
                                .padding(.top, max(proxy.safeAreaInsets.top + 50, 70))

                            features
                                .padding(.top, 22)

                            planList
                                .padding(.top, 26)

                            Text("paywall.cancelAnytime")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white.opacity(0.48))
                                .padding(.top, 12)

                            Button(action: purchaseSelectedPlan) {
                                HStack(spacing: 8) {
                                    if purchaseStore.isPurchasing {
                                        ProgressView()
                                            .tint(.white)
                                    }

                                    Text(primaryButtonKey)

                                    if !purchaseStore.isPurchasing {
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 18, weight: .bold))
                                    }
                                }
                            }
                            .buttonStyle(HabitdotGradientButtonStyle(
                                isEnabled: !isBusy,
                                enabledColors: [Color(hex: 0x55C5FF), Color(hex: 0x1D6DFF)],
                                height: 56
                            ))
                            .disabled(isBusy)
                            .padding(.top, 16)

                            footer
                                .padding(.top, 18)
                                .padding(.bottom, max(proxy.safeAreaInsets.bottom + 20, 34))
                        }
                        .padding(.horizontal, 18)
                        .frame(maxWidth: 520)
                        .frame(maxWidth: .infinity)
                    }

                    header
                        .padding(.horizontal, 18)
                        .padding(.top, max(proxy.safeAreaInsets.top - 46, 0))
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: PaywallLegalDestination.self) { destination in
                LegalDocumentView(document: destination.document)
                    .navigationTitle(Text(LocalizedStringKey(destination.titleKey)))
                    .navigationBarTitleDisplayMode(.inline)
                    .background(Color.habitdotBackground.ignoresSafeArea())
                    .toolbar(.visible, for: .navigationBar)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            recordPaywallView()
            guard !reduceMotion else {
                didAppear = true
                return
            }
            withAnimation(.spring(response: 0.65, dampingFraction: 0.86).delay(0.05)) {
                didAppear = true
            }
        }
        .task {
            await purchaseStore.loadPaywallData()
            store.setProUnlocked(purchaseStore.isProUnlocked)
        }
        .alert("purchase.error.title", isPresented: $isErrorPresented) {
            Button("common.ok", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private var header: some View {
        HStack {
            Button(action: restorePurchases) {
                if purchaseStore.isRestoring {
                    ProgressView()
                        .scaleEffect(0.76)
                        .tint(.white.opacity(0.55))
                } else {
                    Text("paywall.restore")
                }
            }
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white.opacity(0.50))
                .disabled(purchaseStore.isRestoring || purchaseStore.isPurchasing)

            Spacer()

            Button(action: onClose) {
                Text("×")
                    .font(.system(size: 25, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("paywall.close"))
        }
    }

    private var hero: some View {
        VStack(spacing: 10) {
            PaywallDotMark()
                .padding(.bottom, 2)

            Text("paywall.title")
                .font(.system(size: 30, weight: .heavy))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("paywall.subtitle")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white.opacity(0.58))
                .multilineTextAlignment(.center)
        }
        .opacity(didAppear ? 1 : 0)
        .offset(y: didAppear ? 0 : 12)
    }

    private var features: some View {
        VStack(spacing: 10) {
            ForEach(PaywallFeature.all) { feature in
                PaywallFeatureRow(feature: feature)
            }
        }
        .padding(14)
        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.10), lineWidth: 1)
        }
        .opacity(didAppear ? 1 : 0)
        .offset(y: didAppear ? 0 : 16)
        .animation(reduceMotion ? nil : .spring(response: 0.65, dampingFraction: 0.88).delay(0.12), value: didAppear)
    }

    private var planList: some View {
        VStack(spacing: 10) {
            ForEach(HabitdotProPlan.allCases) { plan in
                PaywallPlanRow(
                    plan: plan,
                    priceText: purchaseStore.priceText(for: plan),
                    weeklyPriceText: purchaseStore.weeklyPriceText(for: plan),
                    isSelected: selectedPlan == plan,
                    selectAction: { selectedPlan = plan }
                )
            }
        }
        .opacity(didAppear ? 1 : 0)
        .offset(y: didAppear ? 0 : 20)
        .animation(reduceMotion ? nil : .spring(response: 0.68, dampingFraction: 0.9).delay(0.2), value: didAppear)
    }

    private var footer: some View {
        HStack(spacing: 14) {
            NavigationLink(value: PaywallLegalDestination.privacy) {
                Text("paywall.privacy")
            }
            Text("·")
                .foregroundStyle(.white.opacity(0.32))
            NavigationLink(value: PaywallLegalDestination.terms) {
                Text("paywall.terms")
            }
        }
        .font(.system(size: 13, weight: .semibold))
        .foregroundStyle(.white.opacity(0.46))
    }

    private var isBusy: Bool {
        purchaseStore.isPurchasing || purchaseStore.isRestoring || purchaseStore.isLoadingOfferings
    }

    private var primaryButtonKey: LocalizedStringKey {
        if purchaseStore.isPurchasing {
            return "paywall.purchasing"
        }
        if purchaseStore.isProUnlocked || store.snapshot.settings.isProUnlocked {
            return "paywall.proActive"
        }
        if purchaseStore.isLoadingOfferings {
            return "paywall.loading"
        }
        return "paywall.start"
    }

    private func purchaseSelectedPlan() {
        if purchaseStore.isProUnlocked || store.snapshot.settings.isProUnlocked {
            onStart()
            return
        }

        Task {
            do {
                let isUnlocked = try await purchaseStore.purchase(selectedPlan)
                store.setProUnlocked(isUnlocked)
                if isUnlocked {
                    onStart()
                }
            } catch {
                present(error)
            }
        }
    }

    private func restorePurchases() {
        Task {
            do {
                let isUnlocked = try await purchaseStore.restorePurchases()
                store.setProUnlocked(isUnlocked)
                if isUnlocked {
                    onStart()
                } else {
                    present(message: AppLocalization.localizedString("purchase.restore.notFound"))
                }
            } catch {
                present(error)
            }
        }
    }

    private func recordPaywallView() {
        guard !didRecordPaywallView else { return }
        didRecordPaywallView = true

        Task(priority: .utility) {
            try? await HabitdotPaywallEventService().recordView()
        }
    }

    private func present(_ error: Error) {
        present(message: error.localizedDescription)
    }

    private func present(message: String) {
        errorMessage = message
        isErrorPresented = true
    }
}

private struct PaywallBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: 0x07172E),
                    Color(hex: 0x0B244A),
                    Color(hex: 0x07101D)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [Color(hex: 0x2F8CFF).opacity(0.44), .clear],
                center: .topTrailing,
                startRadius: 10,
                endRadius: 360
            )

            RadialGradient(
                colors: [Color(hex: 0x55D7FF).opacity(0.20), .clear],
                center: .bottomLeading,
                startRadius: 20,
                endRadius: 420
            )
        }
        .ignoresSafeArea()
    }
}

private struct PaywallDotMark: View {
    private let columns = Array(repeating: GridItem(.fixed(10), spacing: 5), count: 9)
    private let activeIndexes: Set<Int> = [2, 5, 9, 10, 14, 17, 20, 21, 22, 25, 28, 30, 33, 34, 37, 38, 39, 41]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 5) {
            ForEach(0..<45, id: \.self) { index in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(activeIndexes.contains(index) ? Color(hex: 0x59C7FF) : .white.opacity(0.11))
                    .frame(width: 10, height: 10)
                    .shadow(color: Color(hex: 0x59C7FF).opacity(activeIndexes.contains(index) ? 0.20 : 0), radius: 5, y: 2)
            }
        }
        .padding(12)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct PaywallFeatureRow: View {
    let feature: PaywallFeature

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: feature.symbolName)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(hex: 0x59C7FF))
                .frame(width: 26, height: 26)
                .background(Color(hex: 0x59C7FF).opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(LocalizedStringKey(feature.titleKey))
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Text(LocalizedStringKey(feature.subtitleKey))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.50))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }
}

private struct PaywallPlanRow: View {
    let plan: HabitdotProPlan
    let priceText: String?
    let weeklyPriceText: String?
    let isSelected: Bool
    let selectAction: () -> Void

    var body: some View {
        Button(action: selectAction) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 7) {
                    HStack(spacing: 9) {
                        Text(LocalizedStringKey(plan.titleKey))
                            .font(.system(size: 19, weight: .heavy))
                            .foregroundStyle(isSelected ? Color(hex: 0x69CFFF) : .white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                            .fixedSize(horizontal: true, vertical: false)

                        if let badgeKey = plan.badgeKey {
                            planBadge(badgeKey)
                        }
                    }

                    Text(LocalizedStringKey(plan.subtitleKey))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(isSelected ? Color(hex: 0x69CFFF).opacity(0.72) : Color(.sRGB, white: 1, opacity: 0.42))
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                }
                .layoutPriority(2)

                Spacer(minLength: 12)

                HStack(spacing: 10) {
                    VStack(alignment: .trailing, spacing: 3) {
                        Group {
                            if let priceText {
                                Text(verbatim: priceText)
                            } else {
                                Text(LocalizedStringKey(plan.fallbackPriceKey))
                            }
                        }
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundStyle(isSelected ? Color(hex: 0x69CFFF) : .white)
                        .minimumScaleFactor(0.72)
                        .lineLimit(1)

                        if let weeklyText = displayWeeklyPriceText {
                            Text(weeklyText)
                                .font(.system(size: 10.5, weight: .heavy))
                                .foregroundStyle(isSelected ? Color(hex: 0x69CFFF).opacity(0.74) : Color(.sRGB, white: 1, opacity: 0.42))
                                .lineLimit(1)
                                .minimumScaleFactor(0.78)
                        }
                    }
                    .fixedSize(horizontal: true, vertical: false)

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color(hex: 0x69CFFF))
                    }
                }
                .layoutPriority(1)
            }
            .padding(.horizontal, 16)
            .frame(height: 82)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(.sRGB, white: 1, opacity: isSelected ? 0.10 : 0.06))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(isSelected ? Color(hex: 0x69CFFF) : Color(.sRGB, white: 1, opacity: 0.12), lineWidth: isSelected ? 2 : 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func planBadge(_ badgeKey: String) -> some View {
        if plan == .annual {
            HStack(spacing: 4) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 9, weight: .black))
                Text(LocalizedStringKey(badgeKey))
                    .font(.system(size: 11, weight: .black))
                    .textCase(.uppercase)
            }
            .foregroundStyle(Color(hex: 0x07172E))
            .lineLimit(1)
            .minimumScaleFactor(0.76)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(
                LinearGradient(
                    colors: [Color(hex: 0xFFE66D), Color(hex: 0xFFB938)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: Capsule()
            )
            .overlay {
                Capsule()
                    .stroke(.white.opacity(0.55), lineWidth: 1)
            }
            .shadow(color: Color(hex: 0xFFB938).opacity(isSelected ? 0.46 : 0.28), radius: 8, y: 3)
        } else {
            Text(LocalizedStringKey(badgeKey))
                .font(.system(size: 10, weight: .heavy))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, 7)
                .padding(.vertical, 4)
                .background(Color(.sRGB, white: 1, opacity: 0.16), in: Capsule())
        }
    }

    private var displayWeeklyPriceText: String? {
        if let weeklyPriceText {
            return weeklyPriceText
        }
        guard let fallbackWeeklyPriceKey = plan.fallbackWeeklyPriceKey else { return nil }
        return AppLocalization.localizedString(fallbackWeeklyPriceKey)
    }
}

private enum PaywallLegalDestination: Hashable {
    case privacy
    case terms

    var titleKey: String {
        switch self {
        case .privacy: "paywall.privacy"
        case .terms: "paywall.terms"
        }
    }

    var document: LegalDocument {
        switch self {
        case .privacy: .privacyPolicy
        case .terms: .termsOfUse
        }
    }
}

private struct PaywallFeature: Identifiable, Sendable {
    let id: String
    let symbolName: String
    let titleKey: String
    let subtitleKey: String

    static let all: [PaywallFeature] = [
        PaywallFeature(
            id: "unlimited",
            symbolName: "infinity",
            titleKey: "paywall.feature.unlimited.title",
            subtitleKey: "paywall.feature.unlimited.subtitle"
        ),
        PaywallFeature(
            id: "purpose",
            symbolName: "scope",
            titleKey: "paywall.feature.purpose.title",
            subtitleKey: "paywall.feature.purpose.subtitle"
        ),
        PaywallFeature(
            id: "ai",
            symbolName: "sparkles",
            titleKey: "paywall.feature.ai.title",
            subtitleKey: "paywall.feature.ai.subtitle"
        ),
        PaywallFeature(
            id: "widgets",
            symbolName: "square.grid.3x3.fill",
            titleKey: "paywall.feature.widgets.title",
            subtitleKey: "paywall.feature.widgets.subtitle"
        ),
        PaywallFeature(
            id: "stats",
            symbolName: "chart.xyaxis.line",
            titleKey: "paywall.feature.stats.title",
            subtitleKey: "paywall.feature.stats.subtitle"
        ),
        PaywallFeature(
            id: "themes",
            symbolName: "paintpalette.fill",
            titleKey: "paywall.feature.themes.title",
            subtitleKey: "paywall.feature.themes.subtitle"
        )
    ]
}
