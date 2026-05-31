import SwiftUI

struct OnboardingCurveView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var progress: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            let plotRect = CGRect(
                x: 48,
                y: 26,
                width: max(1, proxy.size.width - 78),
                height: max(1, proxy.size.height - 88)
            )

            ZStack {
                chartGrid(in: plotRect)
                chartAxes(in: plotRect)
                curveArea(in: plotRect)
                curveLine(in: plotRect)
                curvePoints(in: plotRect)
                chartLabels(in: plotRect)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .onAppear(perform: animateChart)
        .accessibilityLabel(Text("onboarding.proof.chart.accessibility"))
    }

    private var animatedProgress: CGFloat {
        reduceMotion ? 1 : progress
    }

    private func animateChart() {
        progress = reduceMotion ? 1 : 0
        guard !reduceMotion else { return }
        withAnimation(.easeInOut(duration: 1.85).delay(0.18)) {
            progress = 1
        }
    }

    private func chartGrid(in rect: CGRect) -> some View {
        ZStack {
            ForEach(yGuides, id: \.labelKey) { guide in
                let y = point(x: 0, y: guide.value, in: rect).y

                Path { path in
                    path.move(to: CGPoint(x: rect.minX, y: y))
                    path.addLine(to: CGPoint(x: rect.maxX, y: y))
                }
                .stroke(Color.black.opacity(0.16), style: StrokeStyle(lineWidth: 1.2, dash: [6, 7]))
                .opacity(0.25 + animatedProgress * 0.75)

                Text(LocalizedStringKey(guide.labelKey))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.black.opacity(0.72))
                    .rotationEffect(.degrees(-90))
                    .position(x: rect.minX - 28, y: y)
            }
        }
    }

    private func chartAxes(in rect: CGRect) -> some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
                path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))

                path.move(to: CGPoint(x: rect.minX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.minX - 7, y: rect.minY + 10))
                path.move(to: CGPoint(x: rect.minX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.minX + 7, y: rect.minY + 10))

                path.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.maxX - 10, y: rect.maxY - 7))
                path.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.maxX - 10, y: rect.maxY + 7))
            }
            .trim(from: 0, to: animatedProgress)
            .stroke(Color.black.opacity(0.58), style: StrokeStyle(lineWidth: 2.6, lineCap: .round, lineJoin: .round))

            Text("onboarding.proof.axis.happiness")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.78))
                .position(x: rect.minX - 9, y: rect.minY - 16)

            Text("onboarding.proof.axis.stage")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.78))
                .rotationEffect(.degrees(90))
                .position(x: rect.maxX + 22, y: rect.midY + 34)
        }
    }

    private func curveArea(in rect: CGRect) -> some View {
        areaPath(in: rect)
            .fill(
                LinearGradient(
                    colors: [
                        Color.habitdotAccent.opacity(0.34),
                        Color.habitdotPink.opacity(0.16),
                        Color.habitdotPink.opacity(0.02)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .mask(alignment: .leading) {
                Rectangle()
                    .frame(width: rect.minX + rect.width * animatedProgress, height: rect.maxY + 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
    }

    private func curveLine(in rect: CGRect) -> some View {
        ZStack {
            OnboardingFormationCurveShape()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    LinearGradient(
                        colors: [Color.habitdotAccent, Color.habitdotPink],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round)
                )
                .shadow(color: Color.habitdotAccent.opacity(0.20), radius: 8, y: 5)
                .frame(width: rect.width, height: rect.height)
                .position(x: rect.midX, y: rect.midY)

            OnboardingFormationCurveShape()
                .trim(from: 0, to: animatedProgress)
                .stroke(Color.white.opacity(0.48), style: StrokeStyle(lineWidth: 1.4, lineCap: .round))
                .frame(width: rect.width, height: rect.height)
                .position(x: rect.midX, y: rect.midY)
        }
    }

    private func curvePoints(in rect: CGRect) -> some View {
        ZStack {
            ForEach(Array(points.enumerated()), id: \.element.id) { index, curvePoint in
                let location = point(x: curvePoint.x, y: curvePoint.y, in: rect)
                let isVisible = animatedProgress >= curvePoint.revealAt
                let isFinal = index == points.count - 1

                Group {
                    if isFinal {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color(hex: 0x2FC79A))
                            .background(.white, in: Circle())
                    } else {
                        Circle()
                            .fill(.white)
                            .frame(width: 15, height: 15)
                            .overlay {
                                Circle()
                                    .stroke(Color.habitdotAccent, lineWidth: 3)
                            }
                    }
                }
                .scaleEffect(isVisible ? 1 : 0.2)
                .opacity(isVisible ? 1 : 0)
                .animation(.spring(response: 0.34, dampingFraction: 0.7), value: isVisible)
                .position(location)

                Text(LocalizedStringKey(curvePoint.labelKey))
                    .font(.system(size: isFinal ? 16 : 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.black)
                    .fixedSize()
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 8)
                    .animation(.easeOut(duration: 0.24).delay(0.04), value: isVisible)
                    .position(
                        x: min(max(location.x + curvePoint.labelOffset.width, rect.minX + 44), rect.maxX - 34),
                        y: max(location.y + curvePoint.labelOffset.height, rect.minY - 2)
                    )
            }
        }
    }

    private func chartLabels(in rect: CGRect) -> some View {
        ZStack {
            ForEach(stageLabels, id: \.labelKey) { label in
                Text(LocalizedStringKey(label.labelKey))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.black.opacity(0.82))
                    .minimumScaleFactor(0.74)
                    .lineLimit(1)
                    .position(x: point(x: label.x, y: 0, in: rect).x, y: rect.maxY + 24)
            }
        }
    }

    private func curvePath(in rect: CGRect) -> Path {
        let start = CGPoint(x: rect.minX, y: rect.maxY)
        let first = point(x: points[0].x, y: points[0].y, in: rect)
        let second = point(x: points[1].x, y: points[1].y, in: rect)
        let third = point(x: points[2].x, y: points[2].y, in: rect)
        let fourth = point(x: points[3].x, y: points[3].y, in: rect)

        var path = Path()
        path.move(to: start)
        path.addCurve(
            to: first,
            control1: CGPoint(x: rect.minX + rect.width * 0.08, y: rect.maxY - rect.height * 0.08),
            control2: CGPoint(x: rect.minX + rect.width * 0.16, y: rect.maxY - rect.height * 0.14)
        )
        path.addCurve(
            to: second,
            control1: CGPoint(x: rect.minX + rect.width * 0.34, y: rect.maxY - rect.height * 0.08),
            control2: CGPoint(x: rect.minX + rect.width * 0.42, y: rect.maxY - rect.height * 0.20)
        )
        path.addCurve(
            to: third,
            control1: CGPoint(x: rect.minX + rect.width * 0.52, y: rect.maxY - rect.height * 0.48),
            control2: CGPoint(x: rect.minX + rect.width * 0.64, y: rect.maxY - rect.height * 0.56)
        )
        path.addCurve(
            to: fourth,
            control1: CGPoint(x: rect.minX + rect.width * 0.82, y: rect.maxY - rect.height * 0.68),
            control2: CGPoint(x: rect.minX + rect.width * 0.92, y: rect.maxY - rect.height * 0.78)
        )
        return path
    }

    private func areaPath(in rect: CGRect) -> Path {
        var path = curvePath(in: rect)
        path.addLine(to: CGPoint(x: point(x: points[3].x, y: points[3].y, in: rect).x, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }

    private func point(x: CGFloat, y: CGFloat, in rect: CGRect) -> CGPoint {
        CGPoint(
            x: rect.minX + rect.width * x,
            y: rect.maxY - rect.height * y
        )
    }

    private var points: [OnboardingCurvePoint] {
        [
            OnboardingCurvePoint(x: 0.25, y: 0.18, revealAt: 0.26, labelKey: "onboarding.proof.days7", labelOffset: CGSize(width: -12, height: -28)),
            OnboardingCurvePoint(x: 0.47, y: 0.36, revealAt: 0.49, labelKey: "onboarding.proof.days21", labelOffset: CGSize(width: -6, height: -34)),
            OnboardingCurvePoint(x: 0.71, y: 0.64, revealAt: 0.74, labelKey: "onboarding.proof.days66", labelOffset: CGSize(width: 6, height: -34)),
            OnboardingCurvePoint(x: 0.96, y: 0.95, revealAt: 0.94, labelKey: "onboarding.proof.days67", labelOffset: CGSize(width: -24, height: -34))
        ]
    }

    private var yGuides: [OnboardingGuide] {
        [
            OnboardingGuide(value: 0.10, labelKey: "onboarding.proof.percent5"),
            OnboardingGuide(value: 0.28, labelKey: "onboarding.proof.percent15"),
            OnboardingGuide(value: 0.58, labelKey: "onboarding.proof.percent34"),
            OnboardingGuide(value: 0.92, labelKey: "onboarding.proof.percent58")
        ]
    }

    private var stageLabels: [OnboardingStageLabel] {
        [
            OnboardingStageLabel(x: 0.18, labelKey: "onboarding.proof.stage.trigger"),
            OnboardingStageLabel(x: 0.42, labelKey: "onboarding.proof.stage.resistance"),
            OnboardingStageLabel(x: 0.66, labelKey: "onboarding.proof.stage.stabilization"),
            OnboardingStageLabel(x: 0.89, labelKey: "onboarding.proof.stage.automaticity")
        ]
    }
}

private struct OnboardingFormationCurveShape: Shape {
    func path(in rect: CGRect) -> Path {
        let points = [
            CGPoint(x: rect.minX + rect.width * 0.25, y: rect.maxY - rect.height * 0.18),
            CGPoint(x: rect.minX + rect.width * 0.47, y: rect.maxY - rect.height * 0.36),
            CGPoint(x: rect.minX + rect.width * 0.71, y: rect.maxY - rect.height * 0.64),
            CGPoint(x: rect.minX + rect.width * 0.96, y: rect.maxY - rect.height * 0.95)
        ]

        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addCurve(
            to: points[0],
            control1: CGPoint(x: rect.minX + rect.width * 0.08, y: rect.maxY - rect.height * 0.08),
            control2: CGPoint(x: rect.minX + rect.width * 0.16, y: rect.maxY - rect.height * 0.14)
        )
        path.addCurve(
            to: points[1],
            control1: CGPoint(x: rect.minX + rect.width * 0.34, y: rect.maxY - rect.height * 0.08),
            control2: CGPoint(x: rect.minX + rect.width * 0.42, y: rect.maxY - rect.height * 0.20)
        )
        path.addCurve(
            to: points[2],
            control1: CGPoint(x: rect.minX + rect.width * 0.52, y: rect.maxY - rect.height * 0.48),
            control2: CGPoint(x: rect.minX + rect.width * 0.64, y: rect.maxY - rect.height * 0.56)
        )
        path.addCurve(
            to: points[3],
            control1: CGPoint(x: rect.minX + rect.width * 0.82, y: rect.maxY - rect.height * 0.68),
            control2: CGPoint(x: rect.minX + rect.width * 0.92, y: rect.maxY - rect.height * 0.78)
        )
        return path
    }
}

private struct OnboardingCurvePoint: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let revealAt: CGFloat
    let labelKey: String
    let labelOffset: CGSize
}

private struct OnboardingGuide {
    let value: CGFloat
    let labelKey: String
}

private struct OnboardingStageLabel {
    let x: CGFloat
    let labelKey: String
}
