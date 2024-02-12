import Peripheral

import Foundation

class FlipperApplicationAPI: ApplicationAPI {
    private var rpc: Session { pairedDevice.session }
    private let pairedDevice: PairedDevice

    init(pairedDevice: PairedDevice) {
        self.pairedDevice = pairedDevice
    }

    var onAppStateChanged: ((Message.AppState) -> Void)? {
        get { rpc.onAppStateChanged }
        set { rpc.onAppStateChanged = newValue }
    }

    var isLocked: Bool {
        get async throws {
            try await rpc.isApplicationLocked
        }
    }

    func start(_ name: String, args: String) async throws {
        try await rpc.appStart(name, args: args)
    }

    func loadFile(_ path: Peripheral.Path) async throws {
        try await rpc.appLoadFile(path)
    }

    func buttonPress(args: String, index: Int) async throws {
        try await rpc.appButtonPress(args: args, index: index)
    }

    func buttonRelease() async throws {
        try await rpc.appButtonRelease()
    }

    func exit() async throws {
        try await rpc.appExit()
    }
}
