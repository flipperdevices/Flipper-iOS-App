import Foundation

class SVGParser: XMLParser, XMLParserDelegate {
    private(set) var commands: [SVGCommand] = []
    private(set) var height: Double?
    private(set) var width: Double?

    private var isParsingGroup: Bool = true

    override init(data: Data) {
        super.init(data: data)
        self.delegate = self
    }

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        switch elementName {
        case "path":
            guard isParsingGroup else { return }
            parsePathElement(attributes: attributeDict)
        case "rect":
            guard isParsingGroup else { return }
            parseRectElement(attributes: attributeDict)
        case "defs": // Stop parser out of main svg content
            isParsingGroup = false
        case "svg":
            parseSvgMetaElement(attributes: attributeDict)
        default: break
        }
    }

    private func parseSvgMetaElement(attributes: [String: String]) {
        guard
            let width = attributes["width"], let width = Double(width),
            let height = attributes["height"], let height = Double(height)
        else { return }

        self.height = height
        self.width = width
    }

    private func parsePathElement(attributes: [String: String]) {
        guard let dAttribute = attributes["d"] else { return }

        let rawCommands = parseRawCommands(data: dAttribute)
        let svgCommands = rawCommands.map(parseSVGCommand)

        self.commands += svgCommands
    }

    private func parseRawCommands(data: String) -> [String] {
        let supportedTags = "MmLlHhVvZzC"

        var result = [String]()
        var currentCommand = ""

        for character in data {
            if supportedTags.contains(character) {
                if !currentCommand.isEmpty {
                    result.append(currentCommand)
                }
                currentCommand = String(character)
            } else {
                currentCommand.append(character)
            }
        }

        if !currentCommand.isEmpty {
            result.append(currentCommand)
        }

        return result
    }

    private func parseSVGCommand(command: String) -> SVGCommand {
        guard let commandCharacter = command.first else { return .unknown }

        let value = command
            .dropFirst()
            .split(separator: " ")
            .compactMap{ Double($0) }

        switch commandCharacter {
        case "M" where value.count == 2:
            let point = CGPoint(x: value[0], y: value[1])
            return .moveAbsolute(point: point)
        case "m" where value.count == 2:
            return .moveRelative(x: value[0], y: value[1])
        case "L" where value.count == 2:
            let point = CGPoint(x: value[0], y: value[1])
            return .lineToAbsolute(point: point)
        case "l" where value.count == 2:
            return .lineToRelative(x: value[0], y: value[1])
        case "H" where value.count == 1:
            return .horizontalLineToAbsolute(x: value[0])
        case "h"  where value.count == 1:
            return .horizontalLineToRelative(x: value[0])
        case "V"  where value.count == 1:
            return .verticalLineToAbsolute(y: value[0])
        case "v"  where value.count == 1:
            return .verticalLineToRelative(y: value[0])
        case "C" where value.count == 6:
            let x = CGPoint(x: value[0], y: value[1])
            let y = CGPoint(x: value[2], y: value[3])
            let to = CGPoint(x: value[4], y: value[5])
            return .curveToAbsolute(x: x, y: y, to: to)
        case "Z", "z":
            return .closePath
        default:
            return .unknown
        }
    }

    private func parseRectElement(attributes: [String: String]) {
        guard
            let width = attributes["width"], let width = Double(width),
            let height = attributes["height"], let height = Double(height)
        else { return }

        let x = Double(str: attributes["x"]) ?? 0.0
        let y = Double(str: attributes["y"]) ?? 0.0

        let pivot = CGPoint(x: x, y: y)
        let degrees = getDegrees(by: attributes["transform"])

        let rectPoints = [
            CGPoint(x: x, y: y),
            CGPoint(x: x + width, y: y),
            CGPoint(x: x + width, y: y + height),
            CGPoint(x: x, y: y + height)
        ]

        let transformPoints = rectPoints.map { point in
            rotatePoint(
                around: pivot,
                point: point,
                angleDegrees: degrees
            )
        }

        let minX = transformPoints.min(by: { $0.x < $1.x })?.x ?? 0.0
        let maxX = transformPoints.max(by: { $0.x < $1.x })?.x ?? 0.0
        let minY = transformPoints.min(by: { $0.y < $1.y })?.y ?? 0.0
        let maxY = transformPoints.max(by: { $0.y < $1.y })?.y ?? 0.0

        let transformRect = CGRect(
            x: minX,
            y: minY,
            width: maxX - minX,
            height: maxY - minY
        )

        let command = SVGCommand.rect(rect: transformRect)
        self.commands.append(command)
    }

    private func getDegrees(by transform: String?) -> Double {
        guard let data = transform else { return 0 }
        guard data.starts(with: "rotate") else { return 0 }

        let degrees = data
            .replacing("rotate(", with: "")
            .replacing(")", with: "")
            .split(separator: " ")
            .first
            .map { String($0) }

        return Double(str: degrees) ?? 0.0
    }

    private func rotatePoint(
        around pivot: CGPoint,
        point: CGPoint,
        angleDegrees: CGFloat
    ) -> CGPoint {
        let angleRadians = angleDegrees * (.pi / 180)
        let dx = point.x - pivot.x
        let dy = point.y - pivot.y

        let cos = cos(angleRadians)
        let sin = sin(angleRadians)

        let rotatedX = cos * dx - sin * dy + pivot.x
        let rotatedY = sin * dx + cos * dy + pivot.y

        return CGPoint(x: rotatedX, y: rotatedY)
    }
}

fileprivate extension Double {
    init?(str: String?) {
        guard let value = str else { return nil }
        self.init(value)
    }
}
