import Core
import Combine
import Injector
import SwiftUI

class ArchiveViewModel: ObservableObject {
    @Inject var nfc: NFCServiceProtocol
    @Inject var storage: ArchiveStorage

    @Published var items: [ArchiveItem] = [] {
        didSet {
            storage.items = items
        }
    }
    var disposeBag: DisposeBag = .init()

    init() {
        items = storage.items
        nfc.items
            .sink { [weak self] newItems in
                guard let self = self else { return }
                if let item = newItems.first, !self.items.contains(item) {
                    self.items.append(item)
                }
            }
            .store(in: &disposeBag)
    }

    func readNFCTag() {
        nfc.startReader()
    }
}

extension ArchiveItem {
    var icon: Image {
        switch kind {
        case .ibutton: return .init("ibutton")
        case .nfc: return .init("nfc")
        case .rfid: return .init("rfid")
        case .subghz: return .init("subhz")
        }
    }
}
