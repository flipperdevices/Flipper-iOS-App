//
//  Dependencies.swift
//  FlipperZero
//

public func registerDependencies() {
    let container = Container.shared
    container.register(BluetoothService.init, as: BluetoothConnector.self, isSingleton: true)
}
