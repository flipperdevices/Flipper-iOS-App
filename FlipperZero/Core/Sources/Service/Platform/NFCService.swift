import CoreNFC

class NFCService: NSObject, NFCServiceProtocol {
    var session: NFCTagReaderSession?

    private let itemsSubject = SafeSubject([ArchiveItem]())

    var items: SafePublisher<[ArchiveItem]> {
        self.itemsSubject.eraseToAnyPublisher()
    }

    override init() {
        super.init()
        itemsSubject.value = demoData
    }

    func startReader() {
        session = NFCTagReaderSession(
            pollingOption: .iso14443,
            delegate: self,
            queue: DispatchQueue.main)
        session?.begin()
    }
}

extension NFCService: NFCTagReaderSessionDelegate {
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
    }

    func tagReaderSession(
        _ session: NFCTagReaderSession,
        didInvalidateWithError error: Error
    ) {
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        let items = tags.compactMap(ArchiveItem.init)
        itemsSubject.value = items
        session.invalidate()
    }

    func dump(_ tag: NFCTag) {
        print(tag)
    }
}

extension NFCMiFareFamily: CustomStringConvertible {
    // swiftlint:disable switch_case_on_newline
    public var description: String {
        switch self {
        case .unknown: return "Unknown"
        case .ultralight: return "Ultralight"
        case .plus: return "Plus"
        case .desfire: return "Desfire"
        @unknown default: return "Unsupported"
        }
    }
}

fileprivate extension ArchiveItem {
    init?(_ tag: NFCTag) {
        switch tag {
        case let .miFare(tag):
            id = tag.identifier.hexString
            name = "Unnamed"
            description = "ID: " + id
            isFavorite = true
            kind = .nfc
            origin = "Mifare"
        default:
            return nil
        }
    }
}

extension Data {
    var hexString: String {
        map { String(format: "%02hhX", $0) }.joined()
    }
}

let demoData: [ArchiveItem] = [
    .init(
        id: "123",
        name: "Demo card",
        description: "ID: 1234567890",
        isFavorite: true,
        kind: .nfc,
        wut: "Mifare")
]
