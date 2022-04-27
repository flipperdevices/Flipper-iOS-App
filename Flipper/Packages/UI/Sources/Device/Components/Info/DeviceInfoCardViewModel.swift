import Core
import Inject
import Combine
import Peripheral
import Foundation
import SwiftUI

@MainActor
class DeviceInfoCardViewModel: ObservableObject {
    private let appState: AppState = .shared
    private var disposeBag: DisposeBag = .init()

    @Published var device: Flipper?

    var isConnecting: Bool {
        device?.state == .connecting
    }
    var isConnected: Bool {
        device?.state == .connected
    }
    var isDisconnected: Bool {
        device?.state == .disconnected ||
        device?.state == .pairingFailed ||
        device?.state == .invalidPairing
    }
    var isNoDevice: Bool {
        device == nil
    }

    var isInfoLoaded: Bool {
        [firmwareVersion, firmwareBuild, internalSpace, externalSpace]
            .allSatisfy { !$0.isEmpty }
    }

    var _protobufVersion: ProtobufVersion? {
        device?.information?.protobufRevision
    }

    var protobufVersion: String {
        guard isConnected else { return "" }
        guard let version = _protobufVersion else { return "" }
        return version == .unknown ? "—" : version.rawValue
    }

    var firmwareVersion: String {
        guard isConnected else { return "" }
        guard let info = device?.information else { return "" }
        return info.shortSoftwareVersion ?? "invalid"
    }

    var firmwareVersionColor: Color {
        switch firmwareVersion {
        case _ where firmwareVersion.starts(with: "Dev"): return .development
        case _ where firmwareVersion.starts(with: "RC"): return .candidate
        case _ where firmwareVersion.starts(with: "Release"): return .release
        default: return .clear
        }
    }

    var firmwareBuild: String {
        guard isConnected else { return "" }
        guard let info = device?.information else { return "" }

        let build = info
            .softwareRevision
            .split(separator: " ")
            .suffix(1)
            .joined(separator: " ")

        return .init(build)
    }

    var internalSpace: String {
        guard isConnected else { return "—" }
        return device?.storage?.internal?.description ?? ""
    }

    var externalSpace: String {
        guard isConnected else { return "—" }
        return device?.storage?.external?.description ?? "—"
    }

    init() {
        appState.$flipper
            .receive(on: DispatchQueue.main)
            .assign(to: \.device, on: self)
            .store(in: &disposeBag)
    }
}

extension StorageSpace: CustomStringConvertible {
    public var description: String {
        "\(used.hr) / \(total.hr)"
    }
}

fileprivate extension Int {
    var hr: String {
        let formatter = ByteCountFormatter()
        return formatter.string(fromByteCount: Int64(self))
    }
}
