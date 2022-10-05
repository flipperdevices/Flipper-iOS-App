import Core
import Peripheral
import Foundation

public struct WidgetKey: Codable {
    let name: ArchiveItem.Name
    let kind: ArchiveItem.Kind

    var path: Path {
        .init(components: ["any", kind.location, filename])
    }

    var filename: String {
        "\(name).\(kind.extension)"
    }
}
