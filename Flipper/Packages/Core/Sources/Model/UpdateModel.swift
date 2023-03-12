import Peripheral

import Combine
import Foundation

@MainActor
public class UpdateModel: ObservableObject {
    @Published public var state: State = .loading

    @Published public var manifest: Update.Manifest?
    @Published public var updateChannel: Update.Channel = .load() {
        didSet { updateChannel.save() }
    }

    @Published public var intent: Update.Intent?
    @Published public var showUpdate = false

    public var firmware: Update.Firmware? {
        switch updateChannel {
        case .release: return manifest?.release
        case .candidate: return manifest?.candidate
        case .development: return manifest?.development
        }
    }

    public var installed: Update.Version? {
        flipper?.information?.firmwareVersion
    }
    public var available: Update.Version? {
        firmware?.version
    }

    public enum State: Equatable {
        case loading
        case ready(Ready)
        case update(Update)
        case error(Error)

        public enum Ready: Equatable {
            case noUpdates
            case versionUpdate
            case channelUpdate
        }

        public enum Update: Equatable {
            case progress(Progress)
            case result(Result)

            public enum Progress: Equatable {
                case preparing
                case downloading(progress: Double)
                case uploading(progress: Double)
            }

            public enum Result: Equatable {
                case started
                case canceled
            }
        }

        public enum Error: Equatable {
            case noCard
            case noDevice
            case noInternet
            case cantConnect
        }
    }

    private var device: Device

    private let manifestSource: TargetManifestSource
    private let provider: FirmwareProvider
    private let uploader: FirmwareUploader

    private var pairedDevice: PairedDevice
    private var rpc: RPC { pairedDevice.session }
    private var cancellables: [AnyCancellable] = .init()

    public init(
        device: Device,
        pairedDevice: PairedDevice,
        manifestSource: TargetManifestSource
    ) {
        self.device = device
        self.pairedDevice = pairedDevice
        self.manifestSource = manifestSource

        // next step
        self.provider = .init()
        self.uploader = .init(pairedDevice: pairedDevice)

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
        if flipper?.state == .disconnected {
            resetFlipperState()
        }

        if oldValue?.state != .connected {
            updateInstalledManifest()
            updateProvisionedRegion()
            updateCurrentRegion()
        }

        updateState()
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
        state = .update(.progress(.preparing))
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
        state = .loading
        Task {
            do {
                manifest = try await manifestSource.manifest(for: .f7)
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
            case .error(.noCard), .update(.result(.started)):
                return false
            default:
                state = .loading
                return false
            }
        default:
            switch state {
            case .update(.result(.started)):
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

    // MARK: Update

    private var updateTaskHandle: Task<Void, Swift.Error>?

    public func install(_ firmware: Update.Firmware) {
        guard updateTaskHandle == nil else {
            logger.error("update in progress")
            return
        }
        updateTaskHandle = Task {
            do {
                let bytes = try await downloadFirmware(firmware.url)
                let bundle = try await UpdateBundle(unpacking: bytes)

                try await prepareForUpdate()
                try await provideRegion()
                let path = try await uploadFirmware(bundle)
                try await startUpdateProcess(path)
            } catch {
                handleInstallError(error)
                logger.error("update: \(error)")
            }
            updateTaskHandle = nil
        }
    }

    private func handleInstallError(_ error: Swift.Error) {
        switch error {
        case _ as URLError:
            state = .error(.cantConnect)
        case let error as Peripheral.Error
            where error == .storage(.internal):
            state = .error(.noCard)
        default:
            state = .error(.noDevice)
        }
    }

    public func cancel() {
        Task {
            state = .update(.result(.canceled))
            device.disconnect()
            updateTaskHandle = nil
            try? await Task.sleep(milliseconds: 333)
            device.connect()
        }
    }

    private func prepareForUpdate() async throws {
        state = .update(.progress(.preparing))
        try await device.showUpdatingFrame()
    }

    private func provideRegion() async throws {
        state = .update(.progress(.preparing))
        try await device.provideSubGHzRegion()
    }

    private func downloadFirmware(_ url: URL) async throws -> [UInt8] {
        state = .update(.progress(.downloading(progress: 0)))
        return try await provider.data(from: url) { progress in
            Task { @MainActor in
                if case .update(.progress(.downloading)) = self.state {
                    self.state = .update(
                        .progress(.downloading(progress: progress))
                    )
                }
            }
        }
    }

    private func uploadFirmware(
        _ bundle: UpdateBundle
    ) async throws -> Peripheral.Path {
        state = .update(.progress(.preparing))
        return try await uploader.upload(bundle) { progress in
            Task { @MainActor in
                if case .update = self.state {
                    self.state = .update(
                        .progress(.uploading(progress: progress))
                    )
                }
            }
        }
    }

    private func startUpdateProcess(
        _ directory: Peripheral.Path
    ) async throws {
        state = .update(.progress(.preparing))
        try await device.startUpdateProcess(from: directory)
        state = .update(.result(.started))
    }
}

private extension Update.Intent {
    init(from: Update.Version, to: Update.Version) {
        id = Int(Date().timeIntervalSince1970)
        currentVersion = from
        desiredVersion = to
    }
}

private extension Update.Channel {
    static func load() -> Self {
        UserDefaultsStorage.shared.updateChannel
    }

    func save() {
        UserDefaultsStorage.shared.updateChannel = self
    }
}
