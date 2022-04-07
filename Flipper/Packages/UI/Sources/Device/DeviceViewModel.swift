import Core
import Inject
import Peripheral
import Foundation
import Combine

@MainActor
class DeviceViewModel: ObservableObject {
    @Inject var rpc: RPC
    private let appState: AppState = .shared
    private var disposeBag: DisposeBag = .init()

    @Published var showForgetAction = false
    @Published var showPairingIssueAlert = false
    @Published var showUnsupportedVersionAlert = false

    @Published var flipper: Flipper?
    @Published var status: DeviceStatus = .noDevice {
        didSet {
            switch status {
            case .pairingIssue: showPairingIssueAlert = true
            case .unsupportedDevice: showUnsupportedVersionAlert = true
            default: break
            }
        }
    }

    var _protobufVersion: ProtobufVersion? {
        flipper?.information?.protobufRevision
    }

    var protobufVersion: String {
        guard status != .noDevice, status != .disconnected else { return "—" }
        guard let version = _protobufVersion else { return "" }
        return version == .unknown ? "—" : version.rawValue
    }

    var firmwareVersion: String {
        guard status != .noDevice, status != .disconnected else { return "—" }
        guard let info = flipper?.information else { return "" }

        let version = info
            .softwareRevision
            .split(separator: " ")
            .dropFirst()
            .prefix(1)
            .joined()

        return .init(version)
    }

    var firmwareBuild: String {
        guard status != .noDevice, status != .disconnected else { return "—" }
        guard let info = flipper?.information else { return "" }

        let build = info
            .softwareRevision
            .split(separator: " ")
            .suffix(1)
            .joined(separator: " ")

        return .init(build)
    }

    var internalSpace: String {
        guard status != .unsupportedDevice else { return "—" }
        guard status != .noDevice, status != .disconnected else { return "—" }
        return flipper?.storage?.internal?.description ?? ""
    }

    var externalSpace: String {
        guard status != .unsupportedDevice else { return "—" }
        guard status != .noDevice, status != .disconnected else { return "—" }
        return flipper?.storage?.external?.description ?? ""
    }

    init() {
        appState.$flipper
            .receive(on: DispatchQueue.main)
            .assign(to: \.flipper, on: self)
            .store(in: &disposeBag)

        appState.$status
            .receive(on: DispatchQueue.main)
            .assign(to: \.status, on: self)
            .store(in: &disposeBag)
    }

    func showWelcomeScreen() {
        appState.isFirstLaunch = true
    }

    func showForgetActionSheet() {
        showForgetAction = true
    }

    func forgetFlipper() {
        appState.forgetDevice()
    }

    func sync() {
        Task { await appState.synchronize() }
    }

    func playAlert() {
        Task {
            try await rpc.playAlert()
        }
    }
}

extension String {
    static var noDevice: String { "No device" }
    static var unknown: String { "Unknown" }
}

extension StorageSpace: CustomStringConvertible {
    public var description: String {
        "\(used.hr) / \(total.hr)"
    }
}

extension Int {
    var hr: String {
        let formatter = ByteCountFormatter()
        return formatter.string(fromByteCount: Int64(self))
    }
}
