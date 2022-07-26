import Core
import Combine

class NFCEditorViewModel: ObservableObject {
    var item: ArchiveItem

    var bytes: [UInt8?] {
        let blocks = item.properties.filter { $0.key.starts(with: "Block ") }
        guard blocks.count == 64 || blocks.count == 256 else {
            return []
        }
        var result = [UInt8?]()
        for block in blocks {
            print(block)
            let bytes = block
                .value
                .split(separator: " ")
                .map { UInt8($0, radix: 16) }
            result.append(contentsOf: bytes)
        }
        return result
    }

    init(item: ArchiveItem) {
        self.item = item
    }

    func save() {
    }
}
