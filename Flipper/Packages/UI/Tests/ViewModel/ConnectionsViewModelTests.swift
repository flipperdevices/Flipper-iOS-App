import XCTest
import Inject
import Combine

@testable import UI
@testable import Core

class ConnectionsViewModelTests: XCTestCase {
    func testStateWhenBluetoothIsPoweredOff() async {
        let connector = MockBluetoothConnector(initialState: .notReady(.poweredOff)) {
            XCTFail("BluetoothConnector.startScanForPeripherals is called unexpectedly")
        }

        let target = await Self.createTarget(connector)
        let state = await target.state
        XCTAssertEqual(state, .notReady(.poweredOff))
    }

    func testStateWhenBluetoothIsUnauthorized() async {
        let connector = MockBluetoothConnector(initialState: .notReady(.unauthorized)) {
            XCTFail("BluetoothConnector.startScanForPeripherals is called unexpectedly")
        }

        let target = await Self.createTarget(connector)
        let state = await target.state
        XCTAssertEqual(state, .notReady(.unauthorized))
    }

    func testStateWhenBluetoothIsUnsupported() async {
        let connector = MockBluetoothConnector(initialState: .notReady(.unsupported)) {
            XCTFail("BluetoothConnector.startScanForPeripherals is called unexpectedly")
        }

        let target = await Self.createTarget(connector)
        let state = await target.state
        XCTAssertEqual(state, .notReady(.unsupported))
    }

    func testStateWhileScanningDevices() async {
        let startScanExpectation = self.expectation(description: "BluetoothConnector.startScanForPeripherals")
        let connector = MockBluetoothConnector(onStartScanForPeripherals: startScanExpectation.fulfill)

        let target = await Self.createTarget(connector)
        var state = await target.state
        XCTAssertEqual(state, .notReady(.preparing))
        connector.statusSubject.value = .ready
        await self.waitForExpectations(timeout: 0.1)
        state = await target.state
        XCTAssertEqual(state, .ready)
        let peripheral = Peripheral(id: UUID(), name: "Device 42", color: .unknown, state: .disconnected)
        let bluetoothPeripheral = MockPeripheral(id: peripheral.id, name: peripheral.name, state: .disconnected)
        connector.peripheralsSubject.value.append(bluetoothPeripheral)
        let peripherals = await target.peripherals
        XCTAssertEqual(peripherals, [peripheral])
    }

    func testStopScanIsCalledOnDisappear() {
        // TODO: find a way to test onDisappear
    }

    // TODO: Move to generalized mocks
    private static func createTarget(_ connector: BluetoothCentral & BluetoothConnector) async -> ConnectionViewModel {
        let container = Container.shared
        container.register(instance: connector, as: BluetoothCentral.self)
        container.register(instance: connector, as: BluetoothConnector.self)
        container.register(PairedFlipper.init, as: PairedDevice.self, isSingleton: true)
        container.register(DeletedArchiveMock.init, as: DeletedArchiveProtocol.self, isSingleton: true)
        container.register(MobileArchiveMock.init, as: MobileArchiveProtocol.self, isSingleton: true)
        container.register(SynchronizationMock.init, as: SynchronizationProtocol.self, isSingleton: true)
        container.register(DeviceStorageMock.init, as: DeviceStorage.self, isSingleton: true)
        container.register(ArchiveStorageMock.init, as: ArchiveStorage.self, isSingleton: true)
        container.register(ManifestStorageMock.init, as: ManifestStorage.self, isSingleton: true)
        return await ConnectionViewModel()
    }
}

private class MockPeripheral: BluetoothPeripheral {
    var id: UUID
    var name: String = ""
    var color: Peripheral.Color = .unknown
    var state: Peripheral.State = .disconnected
    var services: [Peripheral.Service] = []

    var isPairingFailed: Bool { false }
    var hasProtobufVersion: Bool { true }
    var didDiscoverDeviceInformation: Bool { true }
    var maximumWriteValueLength: Int { 512 }

    var info: SafePublisher<Void> { Empty().eraseToAnyPublisher() }
    var canWrite: SafePublisher<Void> { Empty().eraseToAnyPublisher() }
    var received: SafePublisher<Data> { Empty().eraseToAnyPublisher() }

    init(id: UUID, name: String = "", state: Peripheral.State = .disconnected) {
        self.id = id
        self.name = name
        self.state = state
    }

    func send(_ data: Data) {}
}

private class MockBluetoothConnector: BluetoothCentral, BluetoothConnector {
    private let onStartScanForPeripherals: () -> Void
    private let onStopScanForPeripherals: (() -> Void)?
    private let onConnect: (() -> Void)?
    let statusSubject: SafeValueSubject<BluetoothStatus>
    let peripheralsSubject = SafeValueSubject([BluetoothPeripheral]())
    let connectedPeripheralsSubject: SafeValueSubject<[BluetoothPeripheral]>

    init(
        initialState: BluetoothStatus = .notReady(.preparing),
        connectedPeripherals: [BluetoothPeripheral] = [],
        onStartScanForPeripherals: @escaping () -> Void,
        onStopScanForPeripherals: (() -> Void)? = nil,
        onConnect: (() -> Void)? = nil
    ) {
        self.onStartScanForPeripherals = onStartScanForPeripherals
        self.onStopScanForPeripherals = onStopScanForPeripherals
        self.onConnect = onConnect
        self.statusSubject = SafeValueSubject(initialState)
        self.connectedPeripheralsSubject = SafeValueSubject(connectedPeripherals)
    }

    var peripherals: SafePublisher<[BluetoothPeripheral]> {
        self.peripheralsSubject.eraseToAnyPublisher()
    }

    var connectedPeripherals: SafePublisher<[BluetoothPeripheral]> {
        self.connectedPeripheralsSubject.eraseToAnyPublisher()
    }

    var status: SafePublisher<BluetoothStatus> {
        self.statusSubject.eraseToAnyPublisher()
    }

    func startScanForPeripherals() {
        self.onStartScanForPeripherals()
    }

    func stopScanForPeripherals() {
        self.onStopScanForPeripherals?()
    }

    func connect(to uuid: UUID) {
        self.onConnect?()
    }

    func disconnect(from uuid: UUID) {
    }
}

private class MockStorage: DeviceStorage, ArchiveStorage {
    var pairedDevice: Peripheral? {
        get { nil }
        set { _ = newValue }
    }

    var items: [ArchiveItem] {
        get { [] }
        set { _ = newValue }
    }
}
