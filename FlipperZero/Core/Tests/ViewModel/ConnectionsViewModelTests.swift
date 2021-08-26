@testable import Core
import XCTest

class ConnectionsViewModelTests: XCTestCase {
    func testStateWhenBluetoothIsPoweredOff() {
        let connector = MockBluetoothConnector(initialState: .notReady(.poweredOff)) {
            XCTFail("BluetoothConnector.startScanForPeripherals is called unexpectedly")
        }

        let target = Self.createTarget(connector)
        XCTAssertEqual(target.state, ConnectionsViewModel.State.notReady("Bluetooth is powered off"))
    }

    func testStateWhenBluetoothIsUnauthorized() {
        let connector = MockBluetoothConnector(initialState: .notReady(.unauthorized)) {
            XCTFail("BluetoothConnector.startScanForPeripherals is called unexpectedly")
        }

        let target = Self.createTarget(connector)
        XCTAssertEqual(
            target.state, ConnectionsViewModel.State.notReady("The application is not authorized to use Bluetooth"))
    }

    func testStateWhenBluetoothIsUnsupported() {
        let connector = MockBluetoothConnector(initialState: .notReady(.unsupported)) {
            XCTFail("BluetoothConnector.startScanForPeripherals is called unexpectedly")
        }

        let target = Self.createTarget(connector)
        XCTAssertEqual(target.state, ConnectionsViewModel.State.notReady("Bluetooth is not supported on this device"))
    }

    func testStateWhileScanningDevices() {
        let startScanExpectation = self.expectation(description: "BluetoothConnector.startScanForPeripherals")
        let connector = MockBluetoothConnector(onStartScanForPeripherals: startScanExpectation.fulfill)

        let target = Self.createTarget(connector)
        XCTAssertEqual(target.state, ConnectionsViewModel.State.notReady("Bluetooth is not ready"))
        connector.statusSubject.value = .ready
        self.waitForExpectations(timeout: 0.1)
        XCTAssertEqual(target.state, ConnectionsViewModel.State.scanning([]))
        let peripheral = Peripheral(id: UUID(), name: "Device 42")
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
        return ConnectionsViewModel()
    }
}

private class MockBluetoothConnector: BluetoothConnector {
    private let onStartScanForPeripherals: () -> Void
    private let onStopScanForPeripherals: (() -> Void)?
    let peripheralsSubject = SafeSubject([Peripheral]())
    let statusSubject: SafeSubject<BluetoothStatus>

    init(
        initialState: BluetoothStatus = .notReady(.preparing),
        onStartScanForPeripherals: @escaping () -> Void,
        onStopScanForPeripherals: (() -> Void)? = nil
    ) {
        self.onStartScanForPeripherals = onStartScanForPeripherals
        self.onStopScanForPeripherals = onStopScanForPeripherals
        self.statusSubject = SafeSubject(initialState)
    }

    var peripherals: SafePublisher<[Peripheral]> {
        self.peripheralsSubject.eraseToAnyPublisher()
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
}
