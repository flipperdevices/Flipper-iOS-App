import Inject
import Analytics
import Peripheral

import Logging
import Combine
import Foundation

@MainActor
// swiftlint:disable type_body_length
public class CheckUpdateService: ObservableObject {
    @Published public var state: State = .busy(.connecting)

    @Published public var manifest: Update.Manifest?

    @Published public var installed: Update.Version?
    @Published public var available: Update.Version?

    @Published public var intent: Update.Intent?

    public enum State: Equatable {
        case busy(Busy)
        case ready(Ready)
        case error(Error)

        public enum Busy: Equatable {
            case connecting
            case loadingManifest
            case updateInProgress(Update.Intent)
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

    @Inject private var pairedDevice: PairedDevice
    private var rpc: RPC { pairedDevice.session }
    private var disposeBag: DisposeBag = .init()

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

    public var hasBatteryCharged: Bool {
        guard let battery = flipper?.battery else { return false }
        return battery.level >= 10 || battery.state == .charging
    }

    public init() {
        subscribeToPublishers()
    }

    func subscribeToPublishers() {
        pairedDevice.flipper
            .receive(on: DispatchQueue.main)
            .assign(to: \.flipper, on: self)
            .store(in: &disposeBag)
    }

    // FIXME:
    var channel: Update.Channel {
        .init(rawValue: UserDefaultsStorage.shared.updateChannel)
    }

    func onFlipperChanged(_ oldValue: Flipper?) {
        updateState(channel: channel)

        guard flipper?.state == .connected else {
            resetState()
            return
        }

        if oldValue?.state != .connected {
            verifyManifest()
            verifyRegionData()
            detectCurrentRegion()
        }
    }

    public func onUpdatePressed() {
        guard
            let installed = installed,
            let available = available
        else {
            return
        }

        intent = .init(
            id: Int(Date().timeIntervalSince1970),
            from: installed,
            to: available
        )
    }

    public func onUpdateStarted(_ intent: Update.Intent) {
        // FIXME: wait for event
        state = .busy(.updateInProgress(intent))
    }

    func resetState() {
        hasManifest = .idle
        currentRegion = .idle
        provisionedRegion = .idle
    }

    func verifyManifest() {
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
        }
    }

    func verifyRegionData() {
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
        }
    }

    func detectCurrentRegion() {
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
        }
    }

    public func onNetworkStatusChanged(available: Bool) {
        switch available {
        case true: state = .busy(.connecting)
        case false: state = .error(.noInternet)
        }
    }

    public func updateAvailableFirmware(for channel: Update.Channel) {
        Task {
            do {
                guard state != .error(.noInternet) else { return }
                manifest = try await Update.Manifest.download()
                updateVersion(for: channel)
            } catch {
                state = .error(.cantConnect)
                logger.error("download manifest: \(error)")
            }
        }
    }

    public func updateVersion(for channel: Update.Channel) {
        guard
            let firmware = manifest?.version(for: channel)
        else {
            available = nil
            return
        }

        available = .init(
            channel: channel,
            firmware: firmware)

        updateState(channel: channel)
    }

    // Validating

    func updateState(channel: Update.Channel) {
        guard validateFlipperState() else { return }
        guard validateSDCard() else { return }

        guard validateInstalledFirmware() else { return }
        guard validateAvailableFirmware() else { return }

        guard checkSelectedChannel(channel) else { return }
        guard checkInstalledFirmware() else { return }

        guard validateManifest() else { return }
        guard validateRegion() else { return }

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
                state = .busy(.connecting)
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

    func validateManifest() -> Bool {
        guard case .success(let hasManifest) = hasManifest else {
            return false
        }
        guard hasManifest else {
            state = .ready(.versionUpdate)
            return false
        }
        return true
    }

    func validateRegion() -> Bool {
        let provisionedRegionCode: ISOCode
        let currentRegionCode: ISOCode

        switch provisionedRegion {
        case .success(let region):
            provisionedRegionCode = region
        case .failure:
            state = .ready(.versionUpdate)
            return false
        default:
            return false
        }

        switch currentRegion {
        case .success(let region):
            currentRegionCode = region
        case .failure:
            state = .ready(.versionUpdate)
            return false
        default:
            return false
        }

        guard currentRegionCode == provisionedRegionCode else {
            state = .ready(.versionUpdate)
            return false
        }

        return true
    }

    func validateInstalledFirmware() -> Bool {
        guard let installed = flipper?.information?.firmwareVersion else {
            installed = nil
            return false
        }
        self.installed = installed
        return true
    }

    func validateAvailableFirmware() -> Bool {
        return available != nil
    }

    func checkSelectedChannel(_ channel: Update.Channel) -> Bool {
        guard let installed = installed else {
            return false
        }
        guard installed.channel == channel else {
            state = .ready(.channelUpdate)
            return false
        }
        return true
    }

    func checkInstalledFirmware() -> Bool {
        guard
            let installed = installed,
            let available = available
        else {
            return false
        }
        guard installed.description == available.description else {
            state = .ready(.versionUpdate)
            return false
        }
        return true
    }
}
