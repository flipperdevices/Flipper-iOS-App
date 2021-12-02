import Foundation

@propertyWrapper
public struct Inject<Service> {
    private var service: Service

    public init(container: Resolver = Container.shared) {
        self.service = container.resolve(Service.self)
    }

    public var wrappedValue: Service {
        get { service }
        mutating set { service = newValue }
    }
}
