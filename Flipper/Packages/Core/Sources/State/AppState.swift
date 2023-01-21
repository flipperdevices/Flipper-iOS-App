import Inject
import Analytics
import Peripheral
import Foundation
import Combine
import Logging

@MainActor
public class AppState: ObservableObject {
    @Published public var status: DeviceStatus = .noDevice

    public init() {
        logger.info("app version: \(Bundle.fullVersion)")
        logger.info("log level: \(UserDefaultsStorage.shared.logLevel)")
    }
}
