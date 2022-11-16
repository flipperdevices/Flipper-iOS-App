import Core
import Inject
import Combine
import Peripheral
import Foundation
import SwiftUI

@MainActor
class DeviceInfoCardViewModel: ObservableObject {
    @Inject private var appState: AppState
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
    var isUpdating: Bool {
        appState.status == .updating
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

    var internalSpace: AttributedString {
        guard isConnected, let int = device?.storage?.internal else {
            return ""
        }
        var result = AttributedString(int.description)
        if int.free < 20_000 {
            result.foregroundColor = .sRed
        }
        return result
    }

    var externalSpace: AttributedString {
        guard isConnected, device?.storage?.internal != nil else {
            return ""
        }
        guard let ext = device?.storage?.external else {
            return "—"
        }
        var result = AttributedString(ext.description)
        if ext.free < 100_000 {
            result.foregroundColor = .sRed
        }
        return result
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
