//
//  Inject.swift
//  FlipperZero
//

import Foundation

@propertyWrapper
struct Inject<Service> {
    private var service: Service

    init(container: Resolver = Container.shared) {
        self.service = container.resolve(Service.self)
    }

    var wrappedValue: Service {
        get { service }
        mutating set { service = newValue }
    }
}
