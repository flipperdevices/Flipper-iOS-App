import Inject
import Logging
import Combine
import Dispatch
import Foundation

public class AppState {
    public static let shared: AppState = .init()
    private let logger = Logger(label: "appstate")

    public var isFirstLaunch: Bool {
        get { UserDefaultsStorage.shared.isFirstLaunch }
        set { UserDefaultsStorage.shared.isFirstLaunch = newValue }
    }

    @Inject private var pairedDevice: PairedDevice
    private var disposeBag: DisposeBag = .init()

    @Published public var device: Peripheral? {
        didSet { onDeviceUpdated() }
    }
    @Published public var capabilities: Capabilities?
    @Published public var archive: Archive = .shared
    @Published public var status: Status = .noDevice

    public init() {
        pairedDevice.peripheral
            .receive(on: DispatchQueue.main)
            .assign(to: \.device, on: self)
            .store(in: &disposeBag)
    }

    func onDeviceUpdated() {
        capabilities = .init(device?.protobufVersion)
        updateState(device?.state)
    }

    // MARK: Status

    var connectAttemptCount = 0
    let connectAttemptCountMax = 3

    // swiftlint:disable cyclomatic_complexity
    func updateState(_ newValue: Peripheral.State?) {
        guard let newValue = newValue else {
            status = .noDevice
            return
        }
        switch status {
        // MARK: Pairing
        case .pairing where device?.battery != nil: didConnect()
        case .pairing where newValue == .disconnected: didDisconnect()
        case .noDevice where newValue == .connecting: status = .preParing
        case .preParing where newValue == .connected: status = .pairing
        case .preParing where newValue == .disconnected: didFailToConnect()
        case _ where pairedDevice.isPairingFailed: pairedDevice.forget()
        // MARK: Default
        case .connecting where newValue == .connected: didConnect()
        case .connecting where newValue == .disconnected: didFailToConnect()
        case .connected where newValue == .disconnected: didDisconnect()
        case .synchronizing where newValue == .disconnected: didDisconnect()
        default: status = .init(newValue)
        }
    }

    func didConnect() {
        status = .connected
        connectAttemptCount = 0
        logger.info("connected")
        Task {
            await getStorageInfo()
            await synchronizeDateTime()
            await synchronize()
        }
    }

    func didDisconnect() {
        guard !pairedDevice.isPairingFailed else {
            status = .failed
            logger.debug("disconnected: invalid pincode or canceled")
            return
        }
        status = .disconnected
        logger.debug("disconnected: trying to reconnect")
        connect()
    }

    func didFailToConnect() {
        status = .disconnected
        guard connectAttemptCount >= connectAttemptCountMax else {
            logger.debug("failed to connect: trying again")
            connectAttemptCount += 1
            connect()
            return
        }
        status = .pairingIssue
        logger.debug("failed to connect: pairing issue")
    }

    // MARK: Connection

    public func connect() {
        pairedDevice.connect()
    }

    public func disconnect() {
        pairedDevice.disconnect()
    }

    public func forgetDevice() {
        pairedDevice.forget()
    }

    // MARK: Synchronization

    public func synchronize() async {
        guard status == .connected else { return }
        status = .synchronizing
        await measure("syncing archive") {
            await archive.syncWithDevice()
        }
        status = .init(device?.state)
    }

    func synchronizeDateTime() async {
        guard status == .connected else { return }
        status = .synchronizing
        await measure("setting datetime") {
            try? await RPC.shared.setDate()
        }
        status = .init(device?.state)
    }

    func getStorageInfo() async {
        var storage = device?.storage ?? .init()
        if let intSpace = try? await RPC.shared.getStorageInfo(at: "/int") {
            storage.internal = intSpace
        }
        if let extSpace = try? await RPC.shared.getStorageInfo(at: "/ext") {
            storage.external = extSpace
        }
        device?.storage = storage
    }

    // MARK: Debug

    func measure(_ label: String, _ task: () async -> Void) async {
        let start = Date()
        await task()
        let time = (Date().timeIntervalSince(start) * 1000).rounded() / 1000
        logger.info("\(label): \(time)s")
    }

    // MARK: App Reset

    public func reset() {
        AppReset().reset()
    }
}
