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
    var icon: some View {
        switch kind {
        case .ibutton:
            return Image(systemName: "key")
                .resizable()
                .toAny()
        case .nfc:
            return Image(systemName: "wifi.circle")
                .resizable()
                .rotationEffect(.degrees(90))
                .toAny()
        case .rfid:
            return Image(systemName: "creditcard.and.123")
                .resizable()
                .toAny()
        case .subghz:
            return Image(systemName: "antenna.radiowaves.left.and.right")
                .resizable()
                .toAny()
        }
    }
}

fileprivate extension View {
    func toAny() -> AnyView { AnyView(self) }
}
