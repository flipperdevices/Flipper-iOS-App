//
//  ObservableResolver.swift
//  FlipperZero
//
//  Created by Eugene Berdnikov on 8/23/20.
//

import Combine

public class ObservableResolver: Resolver, ObservableObject {
    private let container: Container

    public init() {
        self.container = Container()
        self.container.register(BluetoothService.init, as: BluetoothConnector.self)
    }

    public func resolve<Service>(_ type: Service.Type) -> Service {
        self.container.resolve(type)
    }
}
