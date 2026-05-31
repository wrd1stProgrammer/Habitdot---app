import SwiftUI

struct BottomTabBarView: View {
    @Environment(HabitStore.self) private var store
    @Namespace private var glassNamespace
    let action: (HabitdotTab) -> Void

    var body: some View {
        if #available(iOS 26.0, *) {
            glassBody
        } else {
            fallbackBody
        }
    }

    @available(iOS 26.0, *)
    private var glassBody: some View {
        ZStack(alignment: .leading) {
            GlassEffectContainer(spacing: 8) {
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.habitdotCard.opacity(0.38))
                        .frame(width: barWidth, height: barHeight)
                        .glassEffect(.regular.tint(.white.opacity(0.12)).interactive(), in: Capsule())
                        .glassEffectID("bottom-tab-base", in: glassNamespace)

                    selectedGlassBubble
                }
            }
            .allowsHitTesting(false)

            tabButtons
                .padding(barPadding)
                .zIndex(1)
        }
        .overlay {
            Capsule()
                .stroke(.white.opacity(0.68), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.12), radius: 24, y: 12)
        .frame(width: barWidth, height: barHeight)
        .animation(.snappy(duration: 0.32, extraBounce: 0.12), value: store.selectedTab)
    }

    private var fallbackBody: some View {
        ZStack(alignment: .leading) {
            selectedFallbackBubble
                .allowsHitTesting(false)

            tabButtons
                .padding(barPadding)
        }
            .background(.ultraThinMaterial, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(.white.opacity(0.70), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.10), radius: 24, y: 12)
            .frame(width: barWidth, height: barHeight)
            .animation(.snappy(duration: 0.32, extraBounce: 0.12), value: store.selectedTab)
    }

    private var tabButtons: some View {
        HStack(spacing: itemSpacing) {
            ForEach(HabitdotTab.allCases) { tab in
                Button(action: { action(tab) }) {
                    Image(systemName: tab.symbolName)
                        .font(.system(size: tab == .add ? 29 : 24, weight: .semibold))
                        .foregroundStyle(foreground(for: tab))
                        .frame(width: itemWidth, height: bubbleHeight)
                        .contentShape(Rectangle())
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(LocalizedStringKey(tab.accessibilityKey)))
            }
        }
    }

    @available(iOS 26.0, *)
    private var selectedGlassBubble: some View {
        Capsule()
            .fill(Color.habitdotCard.opacity(0.50))
            .overlay {
                Capsule()
                    .stroke(.white.opacity(0.88), lineWidth: 1)
            }
            .frame(width: itemWidth, height: bubbleHeight)
            .offset(x: barPadding + CGFloat(selectedIndex) * (itemWidth + itemSpacing))
            .glassEffect(.regular.tint(.white.opacity(0.20)).interactive(), in: Capsule())
            .glassEffectID("bottom-tab-selection", in: glassNamespace)
            .glassEffectTransition(.matchedGeometry)
    }

    private var selectedFallbackBubble: some View {
        Capsule()
            .fill(Color(.systemGray5).opacity(0.84))
            .overlay {
                Capsule()
                    .stroke(.white.opacity(0.86), lineWidth: 1)
            }
            .frame(width: itemWidth, height: bubbleHeight)
            .offset(x: barPadding + CGFloat(selectedIndex) * (itemWidth + itemSpacing))
    }

    private let barWidth: CGFloat = 282
    private let barHeight: CGFloat = 64
    private let barPadding: CGFloat = 6
    private let itemSpacing: CGFloat = 2
    private let bubbleHeight: CGFloat = 52

    private var itemWidth: CGFloat {
        (barWidth - (barPadding * 2) - (itemSpacing * 2)) / 3
    }

    private var selectedIndex: Int {
        HabitdotTab.allCases.firstIndex(of: store.selectedTab) ?? 0
    }

    private func foreground(for tab: HabitdotTab) -> Color {
        if tab == .add {
            return Color.habitdotInk
        }
        return tab == store.selectedTab ? Color.habitdotAccent : Color.habitdotInk
    }
}
