// TODO: Replace with well-known DI container or extend to support resolving with dependencies
public class Container: Resolver {
    public static let shared: Container = .init()

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

    private var factories = [Key: ServiceFactory]()

    public func register<Service>(
        _ builder: @escaping () -> Service,
        as type: Service.Type,
        isSingleton: Bool = false
    ) {
        self.factories[Key(type)] = isSingleton
            ? SingletonFactory(builder)
            : SingleUseFactory(builder)
    }

    public func resolve<Service>(_ type: Service.Type) -> Service {
        guard let factory = self.factories[Key(type)] else {
            fatalError("Factory service for [\(type)] is not registered")
        }

        guard let service = factory.create() as? Service else {
            fatalError("Service created by factory resolved for [\(type)] cannot be casted")
        }

        return service
    }
}

public extension Container {
    func register<Service>(instance: Service) {
        self.register(instance: instance, as: Service.self)
    }

    func register<Service>(instance: Service, as type: Service.Type) {
        self.register({ instance }, as: type, isSingleton: true)
    }

    func register<Service>(_ builder: @escaping () -> Service, isSingleton: Bool = false) {
        self.register(builder, as: Service.self, isSingleton: isSingleton)
    }
}
