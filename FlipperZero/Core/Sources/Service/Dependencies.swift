import Injector

public func registerDependencies() {
    let container = Container.shared
    container.register(BluetoothService.init, as: BluetoothConnector.self, isSingleton: true)
    container.register(UserDefaultsStorage.init, as: LocalStorage.self, isSingleton: true)
}
