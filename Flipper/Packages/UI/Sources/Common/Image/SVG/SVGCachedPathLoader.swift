import Core
import SwiftUI

public class SVGCachedPathLoader {
    public static let shared = SVGCachedPathLoader()

    private let executor: CachedTaskExecutor<URL, SVGData>

    init() {
        self.executor = CachedTaskExecutor<URL, SVGData> { key in
            let data = try await CachedNetworkLoader.shared.get(key)

            let svgParser = SVGParser(data: data)
            svgParser.parse()

            let svgPath = Self.buildPath(commands: svgParser.commands)
            let svgData = SVGData(
                path: svgPath,
                height: svgParser.height ?? 0.0,
                width: svgParser.width ?? 0.0
            )

            return svgData
        }
    }

    public func get(_ url: URL) async throws -> SVGData {
        return try await executor.get(url)
    }

    static func buildPath(commands: [SVGCommand]) -> Path {
        var path = Path()

        commands.forEach {
            switch $0 {
            case .moveAbsolute(let point):
                path.move(to: point)
            case .moveRelative(let x, let y):
                guard let currentPoint = path.currentPoint else { return }

                let point = CGPoint(
                    x: currentPoint.x + x,
                    y: currentPoint.y + y
                )
                path.move(to: point)
            case .lineToAbsolute(let point):
                path.addLine(to: point)
            case .lineToRelative(let x, let y):
                guard let currentPoint = path.currentPoint else { return }

                let point = CGPoint(
                    x: currentPoint.x + x,
                    y: currentPoint.y + y
                )
                path.addLine(to: point)
            case .horizontalLineToAbsolute(let x):
                guard let currentPoint = path.currentPoint else { return }

                let point = CGPoint(
                    x: x,
                    y: currentPoint.y
                )
                path.addLine(to: point)
            case .horizontalLineToRelative(let x):
                guard let currentPoint = path.currentPoint else {
                    return
                }

                let point = CGPoint(
                    x: currentPoint.x + x,
                    y: currentPoint.y
                )
                path.addLine(to: point)
            case .verticalLineToAbsolute(let y):
                guard let currentPoint = path.currentPoint else { return }

                let point = CGPoint(
                    x: currentPoint.x,
                    y: y
                )
                path.addLine(to: point)
            case .verticalLineToRelative(let y):
                guard let currentPoint = path.currentPoint else { return }

                let point = CGPoint(
                    x: currentPoint.x,
                    y: y + currentPoint.y
                )
                path.addLine(to: point)
            case .curveToAbsolute(let control1, let control2, let to):
                path.addCurve(
                    to: to,
                    control1: control1,
                    control2: control2
                )
            case .closePath:
                path.closeSubpath()
            case .rect(let rect):
                path.addRect(rect)
            case .unknown:
                break
            }
        }
        return path
    }
}
