import Core
import Combine
import Injector
import Foundation

class RemoteContolViewModel: ObservableObject {
    @Inject var connector: BluetoothConnector
    private var disposeBag: DisposeBag = .init()

    @Published var frame: ScreenFrame = .init()

    var device: BluetoothPeripheral?

    let rpc: RPC = .shared

    init() {
        connector.connectedPeripherals
            .sink { [weak self] in
                self?.device = $0.first
            }
            .store(in: &disposeBag)

        device?.screenFrame
            .sink { [weak self] in
                self?.onScreenFrame($0)
            }
            .store(in: &disposeBag)
    }

    func startStreaming() {
        print("startStreaming")
        rpc.startStreaming { result in
            print(result)
        }
    }

    func stopStreaming() {
        print("stopStreaming")
        rpc.stopStreaming { result in
            print(result)
        }
    }

    func onScreenFrame(_ frame: ScreenFrame) {
        self.frame = frame
    }

    func onButton(_ button: ControlButton) {
        feedback()
    }
}

import SwiftUI

func feedback() {
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    impactMed.impactOccurred()
}
