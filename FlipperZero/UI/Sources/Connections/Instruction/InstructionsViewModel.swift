import Core
import Combine
import Injector
import SwiftUI

class InstructionsViewModel: ObservableObject {
    @Inject var flipper: PairedDeviceProtocol
    private var disposeBag: DisposeBag = .init()

    @Published var presentConnectionsSheet = false
    @Binding var presentWelcomeSheet: Bool

    @Environment(\.presentationMode) var presentationMode

    init(_ presentWelcomeSheet: Binding<Bool>) {
        _presentWelcomeSheet = presentWelcomeSheet

        flipper.peripheral
            .sink { [weak self] in
                guard let self = self else { return }
                if $0?.state == .connected {
                    self.presentConnectionsSheet = false
                    self.presentWelcomeSheet = false
                }
            }
            .store(in: &disposeBag)
    }
}
