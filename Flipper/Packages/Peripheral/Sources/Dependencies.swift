import Inject
import Logging

public func registerDependencies() {
    let container = Container.shared

    container.register(FlipperFactory.init, as: PeripheralFactory.self, isSingleton: true)

    let central = FlipperCentral()
    container.register(instance: central, as: BluetoothCentral.self)
    container.register(instance: central, as: BluetoothConnector.self)
    container.register(BluetoothRPC.init, as: RPC.self, isSingleton: true)
}
