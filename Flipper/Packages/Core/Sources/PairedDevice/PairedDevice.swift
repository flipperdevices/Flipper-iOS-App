import Peripheral

import Combine

public protocol PairedDevice {
    var session: Session { get }
    var flipper: AnyPublisher<Flipper?, Never> { get }

    func connect()
    func disconnect()
    func forget()

    func updateStorageInfo(_ storageInfo: Flipper.StorageInfo)
}
