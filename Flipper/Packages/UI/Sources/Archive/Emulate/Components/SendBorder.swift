import SwiftUI

struct SendBorder: Shape {
    var cornerRadius: Double

    init(cornerRadius: Double = 12) {
        self.cornerRadius = cornerRadius
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height
        let radius = min(rect.midX, min(rect.midY, cornerRadius))

        path.move(to: .init(x: rect.midX, y: 0))
        path.addLine(to: .init(x: width - radius, y: 0))
        path.addArc(
            center: .init(x: width - radius, y: radius),
            radius: radius,
            startAngle: -90)
        path.addLine(to: .init(x: width, y: height - radius))
        path.addArc(
            center: .init(x: width - radius, y: height - radius),
            radius: radius,
            startAngle: 0)
        path.addLine(to: .init(x: radius, y: height))
        path.addArc(
            center: .init(x: radius, y: height - radius),
            radius: radius,
            startAngle: 90)
        path.addLine(to: .init(x: 0, y: radius))
        path.addArc(
            center: .init(x: radius, y: radius),
            radius: radius,
            startAngle: 180)
        path.closeSubpath()

        return path
    }
}

fileprivate extension Path {
    mutating func addArc(center: CGPoint, radius: Double, startAngle: Double) {
        addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(startAngle),
            endAngle: .degrees(startAngle + 90),
            clockwise: false)
    }
}
