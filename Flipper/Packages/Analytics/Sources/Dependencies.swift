import Inject

public func registerDependencies() {
    let container = Container.shared
    container.register(WantMoarAnalytics.init, as: Analytics.self, isSingleton: true)
}
