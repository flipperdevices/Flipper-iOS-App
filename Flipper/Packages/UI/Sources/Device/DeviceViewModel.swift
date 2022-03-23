import Core
import Combine
import Inject
import Foundation

@MainActor
class DeviceViewModel: ObservableObject {
    @Published var appState: AppState = .shared
    private var disposeBag: DisposeBag = .init()

    @Published var showPairingIssueAlert = false
    @Published var showUnsupportedVersionAlert = false

    @Published var device: Peripheral?
    @Published var status: Status = .noDevice {
        didSet {
            switch status {
            case .pairingIssue: showPairingIssueAlert = true
            case .unsupportedDevice: showUnsupportedVersionAlert = true
            default: break
            }
        }
    }

    var protobufVersion: String? {
        guard device?.isUnsupported == false else {
            return nil
        }
        return device?.information?.protobufRevision ?? "-"
    }

    var firmwareVersion: String {
        guard let info = device?.information else {
            return ""
        }

        let version = info
            .softwareRevision
            .split(separator: " ")
            .dropFirst()
            .prefix(1)
            .joined()

        return .init(version)
    }

    var firmwareBuild: String {
        guard let info = device?.information else {
            return ""
        }

        let build = info
            .softwareRevision
            .split(separator: " ")
            .suffix(1)
            .joined(separator: " ")

        return .init(build)
    }

    var internalSpace: String? {
        guard device?.isUnsupported == false else {
            return nil
        }
        return device?.storage?.internal?.description ?? ""
    }

    var externalSpace: String? {
        guard device?.isUnsupported == false else {
            return nil
        }
        return device?.storage?.external?.description ?? ""
    }

    init() {
        appState.$device
            .receive(on: DispatchQueue.main)
            .assign(to: \.device, on: self)
            .store(in: &disposeBag)

        appState.$status
            .receive(on: DispatchQueue.main)
            .assign(to: \.status, on: self)
            .store(in: &disposeBag)
    }

    func showWelcomeScreen() {
        appState.forgetDevice()
        appState.isFirstLaunch = true
    }

    func sync() {
        Task { await appState.synchronize() }
    }
}

extension String {
    static var noDevice: String { "No device" }
    static var unknown: String { "Unknown" }
}

extension StorageSpace: CustomStringConvertible {
    public var description: String {
        "\(free.hr) / \(total.hr)"
    }
}

extension Int {
    var hr: String {
        let formatter = ByteCountFormatter()
        return formatter.string(fromByteCount: Int64(self))
    }
}
