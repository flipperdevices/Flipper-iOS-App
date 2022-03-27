import Bluetooth

protocol ManifestStorage {
    var manifest: Manifest? { get set }
}

protocol MobileManifestStorage: ManifestStorage {}
protocol DeletedManifestStorage: ManifestStorage {}
protocol SyncedManifestStorage: ManifestStorage {}
