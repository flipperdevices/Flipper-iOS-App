public protocol Resolver {
    func resolve<Service>(_ type: Service.Type) -> Service
}
