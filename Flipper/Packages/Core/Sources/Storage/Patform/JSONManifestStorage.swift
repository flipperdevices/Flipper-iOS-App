class JSONManifestStorage: ManifestStorage {
    let jsonStorage = JSONStorage<Manifest>(
        for: Manifest.self,
        filename: "manifest.json")

    lazy var manifest: Manifest? = { jsonStorage.read() }() {
        didSet {
            if let manifest = manifest {
                jsonStorage.write(manifest)
            } else {
                jsonStorage.delete()
            }
        }
    }
}
