import Foundation
import Peripheral

extension Flipper: PlaintextCodable {
    init(decoding content: String) throws {
        var id: String = ""
        var name: String = ""
        var color: String = ""

        for line in content.split(separator: "\n") {
            let parts = line.split(separator: ":", maxSplits: 1)
            guard let key = parts.first, let value = parts.last else {
                continue
            }
            switch key {
            case "id": id = .init(value)
            case "name": name = .init(value)
            case "color": color = .init(value)
            default: break
            }
        }
        guard let id = UUID(uuidString: id) else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: [], debugDescription: "invalid id"))
        }
        let flipperColor = FlipperColor(rawValue: color) ?? .unknown
        self.init(id: id, name: name, color: flipperColor)
    }

    func encode() throws -> String {
        var result: String = ""
        result.append("id:\(self.id.uuidString)\n")
        result.append("name:\(self.name)\n")
        result.append("color:\(self.color.rawValue)\n")
        return result
    }
}
