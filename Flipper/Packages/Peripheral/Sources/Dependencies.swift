import Inject
import Logging

public func registerDependencies() {
    let container = Container.shared

    let central = FlipperCentral()
    container.register(instance: central, as: BluetoothCentral.self)
    container.register(instance: central, as: BluetoothConnector.self)
    container.register(BluetoothRPC.init, as: RPC.self, isSingleton: true)
}
