import XCTest
import Core
import Injector

@testable import UI

class ConnectionsViewModelTests: XCTestCase {
    func testStateWhenBluetoothIsPoweredOff() {
        let connector = MockBluetoothConnector(initialState: .notReady(.poweredOff)) {
            XCTFail("BluetoothConnector.startScanForPeripherals is called unexpectedly")
        }

        let target = Self.createTarget(connector)
        XCTAssertEqual(target.state, ConnectionsViewModel.State.notReady(.poweredOff))
    }

    func testStateWhenBluetoothIsUnauthorized() {
        let connector = MockBluetoothConnector(initialState: .notReady(.unauthorized)) {
            XCTFail("BluetoothConnector.startScanForPeripherals is called unexpectedly")
        }

        let target = Self.createTarget(connector)
        XCTAssertEqual(
            target.state, ConnectionsViewModel.State.notReady(.unauthorized))
    }

    func testStateWhenBluetoothIsUnsupported() {
        let connector = MockBluetoothConnector(initialState: .notReady(.unsupported)) {
            XCTFail("BluetoothConnector.startScanForPeripherals is called unexpectedly")
        }

        let target = Self.createTarget(connector)
        XCTAssertEqual(target.state, ConnectionsViewModel.State.notReady(.unsupported))
    }

    func testStateWhileScanningDevices() {
        let startScanExpectation = self.expectation(description: "BluetoothConnector.startScanForPeripherals")
        let connector = MockBluetoothConnector(onStartScanForPeripherals: startScanExpectation.fulfill)

        let target = Self.createTarget(connector)
        XCTAssertEqual(target.state, ConnectionsViewModel.State.notReady(.preparing))
        connector.statusSubject.value = .ready
        self.waitForExpectations(timeout: 0.1)
        XCTAssertEqual(target.state, ConnectionsViewModel.State.scanning([]))
        let peripheral = Peripheral(id: UUID(), name: "Device 42", state: .disconnected)
        connector.peripheralsSubject.value.append(peripheral)
        XCTAssertEqual(target.state, ConnectionsViewModel.State.scanning([peripheral]))
    }

    func testStopScanIsCalledOnDeinit() {
        let startScanExpectation = self.expectation(description: "BluetoothConnector.startScanForPeripherals")
        let stopScanExpectation = self.expectation(description: "BluetoothConnector.stopScanForPeripherals")
        let connector = MockBluetoothConnector(
            initialState: .ready,
            onStartScanForPeripherals: startScanExpectation.fulfill,
            onStopScanForPeripherals: stopScanExpectation.fulfill)

        var target: ConnectionsViewModel? = Self.createTarget(connector)
        XCTAssertEqual(target?.state, ConnectionsViewModel.State.scanning([]))
        target = nil
        self.waitForExpectations(timeout: 0.1)
    }

    private static func createTarget(_ connector: BluetoothConnector) -> ConnectionsViewModel {
        let container = Container.shared
        container.register(instance: connector, as: BluetoothConnector.self)
        container.register(MockStorage.init, as: LocalStorage.self)
        return ConnectionsViewModel()
    }
}

private class MockBluetoothConnector: BluetoothConnector {
    private let onStartScanForPeripherals: () -> Void
    private let onStopScanForPeripherals: (() -> Void)?
    private let onConnect: (() -> Void)?
    let peripheralsSubject = SafeSubject([Peripheral]())
    let statusSubject: SafeSubject<BluetoothStatus>
    var connectedPeripheralSubject: SafeSubject<Peripheral?>

    init(
        initialState: BluetoothStatus = .notReady(.preparing),
        connectedPeripheral: Peripheral? = nil,
        onStartScanForPeripherals: @escaping () -> Void,
        onStopScanForPeripherals: (() -> Void)? = nil,
        onConnect: (() -> Void)? = nil
    ) {
        self.onStartScanForPeripherals = onStartScanForPeripherals
        self.onStopScanForPeripherals = onStopScanForPeripherals
        self.onConnect = onConnect
        self.statusSubject = SafeSubject(initialState)
        self.connectedPeripheralSubject = SafeSubject(connectedPeripheral)
    }

    var peripherals: SafePublisher<[Peripheral]> {
        self.peripheralsSubject.eraseToAnyPublisher()
    }

    var connectedPeripheral: SafePublisher<Peripheral?> {
        self.connectedPeripheralSubject.eraseToAnyPublisher()
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

    func forget(about uuid: UUID) {
    }
}

private class MockStorage: LocalStorage {
    var lastConnectedDevice: UUID? {
        get { nil }
        set { _ = newValue }
    }
}
