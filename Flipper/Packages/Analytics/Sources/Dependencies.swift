import Inject

public func registerDependencies() {
    let container = Container.shared
    container.register(CountlyAnalytics.init, as: Analytics.self, isSingleton: true)
}
