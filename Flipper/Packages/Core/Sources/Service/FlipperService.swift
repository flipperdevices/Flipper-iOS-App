import Inject
import Peripheral

import Logging
import Combine

@MainActor
public class FlipperService: ObservableObject {
    private let logger = Logger(label: "flipper-service")

    @Inject var rpc: RPC

    @Published public private(set) var frame: ScreenFrame = .init()

    @Published public private(set) var deviceInfo: [String: String] = [:]
    @Published public private(set) var powerInfo: [String: String] = [:]
    @Published public private(set) var isInfoReady = false

    public init() {
        subscribeToPublishers()
    }

    private func subscribeToPublishers() {
        rpc.onScreenFrame { [weak self] frame in
            guard let self else { return }
            Task { @MainActor in
                self.frame = frame
            }
        }
    }

    public func startScreenStreaming() {
        Task {
            do {
                try await rpc.startStreaming()
            } catch {
                logger.error("start streaming: \(error)")
            }
        }
    }

    public func stopScreenStreaming() {
        Task {
            do {
                try await rpc.stopStreaming()
            } catch {
                logger.error("stop streaming: \(error)")
            }
        }
    }

    public func pressButton(_ button: InputKey) {
        Task {
            do {
                try await rpc.pressButton(button)
            } catch {
                logger.error("press button: \(error)")
            }
        }
    }

    public func playAlert() {
        Task {
            do {
                try await rpc.playAlert()
            } catch {
                logger.error("play alert intent: \(error)")
            }
        }
    }

    public func reboot() {
        Task {
            do {
                try await rpc.reboot(to: .os)
            } catch {
                logger.error("reboot flipper: \(error)")
            }
        }
    }


    private var isProvisioningDisabled: Bool {
        get {
            UserDefaultsStorage.shared.isProvisioningDisabled
        }
    }

    private var hardwareRegion: Int? {
        get async throws {
            let info = try await rpc.deviceInfo()
            return Int(info["hardware_region"] ?? "")
        }
    }

    private var canDisableProvisioning: Bool {
        get async {
            (try? await hardwareRegion) == 0
        }
    }

    public func provideSubGHzRegion() async throws {
        if isProvisioningDisabled, await canDisableProvisioning {
            return
        }
        try await rpc.writeFile(
            at: Provisioning.location,
            bytes: Provisioning().provideRegion().encode())
    }

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

    public func getInfo() async {
        isInfoReady = false
        await getDeviceInfo()
        await getPowerInfo()
        isInfoReady = true
    }

    public func getDeviceInfo() async {
        do {
            for try await (key, value) in rpc.deviceInfo() {
                deviceInfo[key] = value
            }
        } catch {
            logger.error("device info: \(error)")
        }
    }

    public func getPowerInfo() async {
        do {
            for try await (key, value) in rpc.powerInfo() {
                powerInfo[key] = value
            }
        } catch {
            logger.error("power info: \(error)")
        }
    }
}
