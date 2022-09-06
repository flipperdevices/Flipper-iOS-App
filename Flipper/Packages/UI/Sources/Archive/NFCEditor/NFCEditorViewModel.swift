import Core
import Combine

@MainActor
class NFCEditorViewModel: ObservableObject {
    var item: ArchiveItem

    let appState: AppState = .shared
    var archive: Archive { appState.archive }

    @Published var bytes: [UInt8?]

    init(item: ArchiveItem) {
        self.item = item
        self.bytes = item.nfcBlocks
    }

    func save() {
        item.nfcBlocks = bytes
        Task {
            try await archive.upsert(item)
            try await appState.synchronize()
        }
    }
}

extension ArchiveItem {
    var nfcBlocks: [UInt8?] {
        get {
            let properties = shadowCopy.isEmpty
                ? self.properties
                : self.shadowCopy
            let blocks = properties.filter { $0.key.starts(with: "Block ") }
            guard blocks.count == 64 || blocks.count == 256 else {
                return []
            }
            var result = [UInt8?]()
            for block in blocks {
                let bytes = block
                    .value
                    .split(separator: " ")
                    .map { UInt8($0, radix: 16) }
                result.append(contentsOf: bytes)
            }
            return result
        }
        set {
            guard newValue.count == 1024 || newValue.count == 4096 else {
                return
            }
            if shadowCopy.isEmpty {
                shadowCopy = properties
            }
            for block in 0..<newValue.count / 16 {
                var startIndex: Int { block * 16 }
                var endIndex: Int { startIndex + 16 }
                let bytes: [String] = newValue[startIndex..<endIndex].map {
                    guard let byte = $0 else {
                        return "??"
                    }
                    return byte < 16
                        ? "0" + String(byte, radix: 16).uppercased()
                        : String(byte, radix: 16).uppercased()
                }
                if let index = shadowCopy.index(of: "Block \(block)") {
                    shadowCopy[index].value = bytes.joined(separator: " ")
                }
            }
        }
    }
}

fileprivate extension Array where Element == ArchiveItem.Property {
    func index(of key: String) -> Int? {
        self.firstIndex { $0.key == key }
    }
}
