import Bluetooth

protocol ManifestStorage {
    var manifest: Manifest? { get set }
}

protocol MobileManifestStorage: ManifestStorage {}
protocol SyncedManifestStorage: ManifestStorage {}
