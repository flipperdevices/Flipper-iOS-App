import Inject

public func registerMockDependencies() {
    let container = Container.shared
    container.register(AnalyticMock.init, as: Analytics.self, isSingleton: true)
}
