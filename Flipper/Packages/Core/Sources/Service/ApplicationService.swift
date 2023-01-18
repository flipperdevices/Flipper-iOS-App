import Inject
import Analytics

import Combine
import Logging
import Foundation

@MainActor
public class ApplicationService: ObservableObject {
    private let logger = Logger(label: "application-service")

    private var disposeBag: DisposeBag = .init()

    public init() {
        subscribeToPublishers()
    }

    func subscribeToPublishers() {
    }

    // MARK: App Reset

    public func reset() {
        AppReset().reset()
    }

    // MARK: Analytics

    func recordAppOpen() {
        analytics.appOpen(target: .app)
    }
}
