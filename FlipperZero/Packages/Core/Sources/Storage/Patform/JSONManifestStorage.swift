class JSONManifestStorage: ManifestStorage {
    static let shared: JSONManifestStorage = .init()

    let jsonStorage = JSONStorage<Manifest>(
        for: Manifest.self,
        filename: "manifest.json")

    var manifest: Manifest? {
        get {
            jsonStorage.read()
        }
        set {
            if let manifest = newValue {
                jsonStorage.write(manifest)
            } else {
                jsonStorage.delete()
            }
        }
    }
}
