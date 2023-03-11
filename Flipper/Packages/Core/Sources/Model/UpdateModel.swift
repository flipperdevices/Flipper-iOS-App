import Peripheral

import Combine
import Foundation

@MainActor
public class UpdateModel: ObservableObject {
    @Published public var state: State = .busy(.checkingForUpdate)

    @Published public var firmware: Update.Firmware?

    public var installed: Update.Version? {
        flipper?.information?.firmwareVersion
    }
    public var available: Update.Version? {
        firmware?.version
    }

    @Published public var intent: Update.Intent?
    @Published public var showUpdate = false

    public var updateChannel: Update.Channel {
        get {
            UserDefaultsStorage.shared.updateChannel
        }
        set {
            UserDefaultsStorage.shared.updateChannel = newValue
            updateAvailableFirmware()
        }
    }

    public enum State: Equatable {
        case busy(Busy)
        case ready(Ready)
        case error(Error)

        public enum Busy: Equatable {
            case checkingForUpdate
            case updateInProgress
        }

        public enum Ready: Equatable {
            case noUpdates
            case versionUpdate
            case channelUpdate
        }

        public enum Error: Equatable {
            case noCard
            case noDevice
            case noInternet
            case cantConnect
        }
    }

    private let updateSource: UpdateSource

    private var pairedDevice: PairedDevice
    private var rpc: RPC { pairedDevice.session }
    private var cancellables: [AnyCancellable] = .init()

    public init(pairedDevice: PairedDevice, updateSource: UpdateSource) {
        self.pairedDevice = pairedDevice
        self.updateSource = updateSource
        subscribeToPublishers()
    }

    @Published var flipper: Flipper? {
        didSet { onFlipperChanged(oldValue) }
    }

    var hasManifest: LazyResult<Bool, Swift.Error> = .idle
    var currentRegion: LazyResult<ISOCode, Swift.Error> = .idle
    var provisionedRegion: LazyResult<ISOCode, Swift.Error> = .idle

    var hasSDCard: LazyResult<Bool, Swift.Error> {
        guard let storage = flipper?.storage else { return .working }
        return .success(storage.external != nil)
    }

    func subscribeToPublishers() {
        pairedDevice.flipper
            .receive(on: DispatchQueue.main)
            .assign(to: \.flipper, on: self)
            .store(in: &cancellables)
    }

    func onFlipperChanged(_ oldValue: Flipper?) {
        guard flipper?.state == .connected else {
            resetFlipperState()
            return
        }

        if oldValue?.state != .connected {
            updateInstalledManifest()
            updateProvisionedRegion()
            updateCurrentRegion()
        }

        // FIXME: use async api to check sd card
        if oldValue?.storage != flipper?.storage {
            updateState()
        }
    }

    func resetFlipperState() {
        hasManifest = .idle
        currentRegion = .idle
        provisionedRegion = .idle
    }

    public func startUpdate() {
        guard
            let installed = installed,
            let available = available
        else {
            return
        }
        intent = .init(from: installed, to: available)
        showUpdate = true
        state = .busy(.updateInProgress)
    }

    func updateInstalledManifest() {
        guard case .idle = hasManifest else { return }
        hasManifest = .working
        Task {
            do {
                _ = try await rpc.getSize(at: .manifest)
                hasManifest = .success(true)
            } catch {
                logger.error("verify manifest: \(error)")
                hasManifest = .success(false)
            }
            updateState()
        }
    }

    func updateProvisionedRegion() {
        guard case .idle = provisionedRegion else { return }
        provisionedRegion = .working
        Task {
            do {
                let bytes = try await rpc.readFile(at: Provisioning.location)
                let region = try Provisioning.Region(decoding: bytes)
                provisionedRegion = .success(region.code)
            } catch {
                logger.error("verify region: \(error)")
                provisionedRegion = .failure(error)
            }
            updateState()
        }
    }

    func updateCurrentRegion() {
        guard case .idle = currentRegion else { return }
        currentRegion = .working
        Task {
            do {
                let region = try await Provisioning().provideRegion().code
                currentRegion = .success(region)
            } catch {
                logger.error("check region change: \(error)")
                currentRegion = .failure(error)
            }
            updateState()
        }
    }

    public func updateAvailableFirmware() {
        guard state != .error(.noInternet) else { return }
        state = .busy(.checkingForUpdate)
        Task {
            do {
                firmware = try await updateSource.firmware(
                    for: .f7,
                    channel: updateChannel)
                updateState()
            } catch {
                state = .error(.cantConnect)
                logger.error("download manifest: \(error)")
            }
        }
    }

    func updateState() {
        guard validateFlipperState() else { return }
        guard validateSDCard() else { return }

        guard validateInstalledFirmware() else { return }
        guard validateAvailableFirmware() else { return }

        guard checkChannelUpdate() else { return }
        guard checkVersionUpdate() else { return }

        guard checkManifestUpdate() else { return }
        guard checkRegionUpdate() else { return }

        state = .ready(.noUpdates)
    }

    func validateFlipperState() -> Bool {
        guard let flipper = flipper else { return false }

        switch flipper.state {
        case .connected:
            return true
        case .connecting:
            switch state {
            case .error(.noCard), .busy(.updateInProgress):
                return false
            default:
                state = .busy(.checkingForUpdate)
                return false
            }
        default:
            switch state {
            case .busy(.updateInProgress):
                return false
            default:
                state = .error(.noDevice)
                return false
            }
        }
    }

    func validateSDCard() -> Bool {
        guard case .success(let hasSDCard) = hasSDCard else {
            return false
        }
        guard hasSDCard else {
            state = .error(.noCard)
            return false
        }
        return true
    }

    func validateInstalledFirmware() -> Bool {
        installed != nil
    }

    func validateAvailableFirmware() -> Bool {
        available != nil
    }

    func checkManifestUpdate() -> Bool {
        guard case .success(let hasManifest) = hasManifest else {
            return false
        }
        guard hasManifest else {
            state = .ready(.versionUpdate)
            return false
        }
        return true
    }

    func checkRegionUpdate() -> Bool {
        guard
            case .success(let provisionedRegionCode) = provisionedRegion,
            case .success(let currentRegionCode) = currentRegion,
            currentRegionCode == provisionedRegionCode
        else {
            state = .ready(.versionUpdate)
            return false
        }
        return true
    }

    func checkChannelUpdate() -> Bool {
        guard let installed = installed else {
            return false
        }
        guard installed.channel == updateChannel else {
            state = .ready(.channelUpdate)
            return false
        }
        return true
    }

    func checkVersionUpdate() -> Bool {
        guard
            let installed = installed,
            let available = available
        else {
            return false
        }
        guard installed == available else {
            state = .ready(.versionUpdate)
            return false
        }
        return true
    }
}

extension Update.Intent {
    init(from: Update.Version, to: Update.Version) {
        id = Int(Date().timeIntervalSince1970)
        currentVersion = from
        desiredVersion = to
    }
}
