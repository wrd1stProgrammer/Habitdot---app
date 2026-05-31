import SwiftUI

struct ChartLikeCurve: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + 8, y: rect.maxY - 18))
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.midY + 10),
            control1: CGPoint(x: rect.width * 0.18, y: rect.maxY - 52),
            control2: CGPoint(x: rect.width * 0.28, y: rect.midY + 32)
        )
        path.addCurve(
            to: CGPoint(x: rect.maxX - 12, y: rect.minY + 26),
            control1: CGPoint(x: rect.width * 0.66, y: rect.midY - 18),
            control2: CGPoint(x: rect.width * 0.78, y: rect.minY + 30)
        )
        return path
    }
}
