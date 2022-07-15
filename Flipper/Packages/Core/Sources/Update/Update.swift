import Inject
import Peripheral
import Foundation
import Logging

public class Update {
    let logger = Logger(label: "update")

    @Inject var rpc: RPC

    public enum Channel {
        case development
        case canditate
        case release
        case custom(URL)
    }

    public enum Error: Swift.Error {
        case invalidFirmware
        case invalidFirmwareURL
        case invalidFirmwareURLString
        case invalidFirmwareCloudDocument
    }

    public init() {}

    public func showUpdatingFrame() async throws {
        try await rpc.startVirtualDisplay(with: .updateInProgress)
    }

    public func hideUpdatingFrame() async throws {
        try await rpc.stopVirtualDisplay()
    }

    public func startUpdateProcess(from path: Path) async throws {
        try await rpc.update(manifest: path.appending("update.fuf"))
        try await rpc.reboot(to: .update)
    }
}

extension Update.Channel: RawRepresentable {
    public var rawValue: String {
        switch self {
        case .release: return "release"
        case .canditate: return "canditate"
        default: return "development"
        }
    }

    public init(rawValue: String) {
        switch rawValue {
        case "release": self = .release
        case "canditate": self = .canditate
        default: self = .development
        }
    }
}
