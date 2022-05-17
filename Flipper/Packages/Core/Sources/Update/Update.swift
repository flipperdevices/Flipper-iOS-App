import Inject
import Peripheral
import Foundation
import Logging

public class Update {
    let logger = Logger(label: "update")

    @Inject var rpc: RPC

    public enum Channel: String {
        case development
        case canditate
        case release
    }

    public enum Error: Swift.Error {
        case invalidFirmware
        case invalidFirmwareURL
    }

    public init() {}

    public func showUpdatingFrame() async throws {
        try await rpc.startVirtualDisplay(with: .updateInProgress)
    }

    public func hideUpdatingFrame() async throws {
        try await rpc.stopVirtualDisplay()
    }

    public func startUpdateProcess(from directory: String) async throws {
        try await rpc.update(manifest: directory + "update.fuf")
        try await rpc.reboot(to: .update)
    }
}
