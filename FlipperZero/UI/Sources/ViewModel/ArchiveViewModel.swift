import Core
import Combine
import Injector
import SwiftUI

class ArchiveViewModel: ObservableObject {
    @Inject var nfc: NFCServiceProtocol

    @Published var items: [ArchiveItem] = []
    var disposeBag: DisposeBag = .init()

    init() {
        nfc.items
            .sink { newItems in
                self.items.removeAll { item in
                    newItems.contains { $0.id == item.id }
                }
                self.items.append(contentsOf: newItems)
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
