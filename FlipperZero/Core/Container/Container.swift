//
//  Container.swift
//  FlipperZero
//
//  Created by Eugene Berdnikov on 8/23/20.
//

// TODO: Replace with well-known DI container or extend to support resolving with dependencies
class Container: Resolver {
    typealias Factory = () -> Any

    private struct Key: Hashable {
        private let type: Any.Type

        init(_ type: Any.Type) {
            self.type = type
        }

        func hash(into hasher: inout Hasher) {
            ObjectIdentifier(self.type).hash(into: &hasher)
        }

        static func == (lhs: Container.Key, rhs: Container.Key) -> Bool {
            lhs.type == rhs.type
        }
    }

    private var factories = [Key: Factory]()

    func register<Service>(_ service: Service) {
        self.register(service, as: Service.self)
    }

    func register<Service>(_ service: Service, as type: Service.Type) {
        self.register({ service }, as: type)
    }

    func register<Service>(_ factory: @escaping Factory, as type: Service.Type) {
        self.factories[Key(type)] = factory
    }

    func resolve<Service>(_ type: Service.Type) -> Service {
        guard let factory = self.factories[Key(type)] else {
            fatalError("Factory service for [\(type)] is not registered")
        }

        guard let service = factory() as? Service else {
            fatalError("Service returned by factory resolved for [\(type)] cannot be casted")
        }

        return service
    }
}
