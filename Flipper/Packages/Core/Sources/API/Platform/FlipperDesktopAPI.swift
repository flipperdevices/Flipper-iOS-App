import Peripheral

import Foundation

class FlipperDesktopAPI: DesktopAPI {
    private var rpc: Session { pairedDevice.session }
    private let pairedDevice: PairedDevice

    init(pairedDevice: PairedDevice) {
        self.pairedDevice = pairedDevice
    }

    var isLocked: Bool {
        get async throws {
            try await rpc.isDesktopLocked
        }
    }

    func unlock() async throws {
        try await rpc.unlock()
    }
}
