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
            for offset in 0..<newValue.count / 16 {
                let bytes = newValue[offset..<(offset + 16)].map { byte in
                    guard let byte = byte else {
                        return "??"
                    }
                    return byte < 16
                        ? "0" + String(byte, radix: 16).uppercased()
                        : String(byte, radix: 16).uppercased()
                }
                if let index = properties.firstIndex(where: { $0.key == "Block \(offset)" }) {
                    properties[index].value = bytes.joined(separator: " ")
                    print(properties[index])
                }
            }
        }
    }
}
