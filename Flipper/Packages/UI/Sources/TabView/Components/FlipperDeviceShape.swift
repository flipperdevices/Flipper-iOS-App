import SwiftUI

struct DeviceTabShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // M6.97885 4.21049
        path.move(to: CGPoint(x: 6.97885, y: 4.21049))

        // C7.58029 3.29869 8.59953 2.75 9.69181 2.75
        path.addCurve(
            to: CGPoint(x: 9.69181, y: 2.75),
            control1: CGPoint(x: 7.58029, y: 3.29869),
            control2: CGPoint(x: 8.59953, y: 2.75)
        )

        // H34.4303
        guard let currentPoint = path.currentPoint else { return path }
        path.addLine(to: CGPoint(x: 34.4303, y: currentPoint.y))

        // C35.5326 2.75 36.5597 3.30868 37.1586 4.23401
        path.addCurve(
            to: CGPoint(x: 37.1586, y: 4.23401),
            control1: CGPoint(x: 35.5326, y: 2.75),
            control2: CGPoint(x: 36.5597, y: 3.30868)
        )

        // L40.7283 9.74894
        path.addLine(to: CGPoint(x: 40.7283, y: 9.74894))

        // C41.0688 10.275 41.25 10.8883 41.25 11.5149
        path.addCurve(
            to: CGPoint(x: 41.25, y: 11.5149),
            control1: CGPoint(x: 41.0688, y: 10.275),
            control2: CGPoint(x: 41.25, y: 10.8883)
        )

        // V18
        guard let currentPoint = path.currentPoint else { return path }
        path.addLine(to: CGPoint(x: currentPoint.x, y: 18))

        // C41.25 19.7949 39.7949 21.25 38 21.25
        path.addCurve(
            to: CGPoint(x: 38, y: 21.25),
            control1: CGPoint(x: 41.25, y: 19.7949),
            control2: CGPoint(x: 39.7949, y: 21.25)
        )

        // H9.34742
        guard let currentPoint = path.currentPoint else { return path }
        path.addLine(to: CGPoint(x: 9.34742, y: currentPoint.y))

        // C8.41312 21.25 7.52401 20.8479 6.90698 20.1463
        path.addCurve(
            to: CGPoint(x: 6.90698, y: 20.1463),
            control1: CGPoint(x: 8.41312, y: 21.25),
            control2: CGPoint(x: 7.52401, y: 20.8479)
        )

        // L2.5807 15.2272
        path.addLine(to: CGPoint(x: 2.5807, y: 15.2272))

        // C1.61287 14.1268 1.50125 12.5147 2.30818 11.2914
        path.addCurve(
            to: CGPoint(x: 2.30818, y: 11.2914),
            control1: CGPoint(x: 1.61287, y: 14.1268),
            control2: CGPoint(x: 1.50125, y: 12.5147)
        )

        // Z
        path.closeSubpath()

        return path
    }
}

extension DeviceTabShape {
    func form(isFill: Bool, _ color: Color) -> some View {
        if isFill {
            return AnyView(fill(color))
        } else {
            return AnyView(stroke(color, lineWidth: 1.5))
        }
    }
}
