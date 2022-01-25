import Inject
import Darwin

class AppReset {
    @Inject var archiveStorage: ArchiveStorage
    @Inject var deviceStorage: DeviceStorage
    @Inject var manifestStorage: ManifestStorage

    func reset() {
        UserDefaultsStorage.shared.reset()
        archiveStorage.items = []
        deviceStorage.pairedDevice = nil
        manifestStorage.manifest = nil
        exit(0)
    }
}
