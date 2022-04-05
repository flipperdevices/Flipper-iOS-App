import Inject
import Logging

public func registerMockDependencies() {
    let container = Container.shared

    let central = BluetoothCentralMock(status: .notReady(.preparing))
    container.register(instance: central, as: BluetoothCentral.self)
    container.register(instance: central, as: BluetoothConnector.self)
    container.register(RPCMock.init, as: RPC.self, isSingleton: true)
}
