import Foundation

public func migration() async {
    // check if version is changed
    guard UserDefaults.lastVersion != Bundle.fullVersion else {
        return
    }

    defer {
        UserDefaults.lastRelease = Bundle.releaseVersion
        UserDefaults.lastBuild = Bundle.buildVersion
    }

    // guard pre-migration apps
    guard UserDefaults.lastVersion != "()" else {
        await resetStorage()
        return
    }
    guard // ignore developer build
        let previousBuild = Int(UserDefaults.lastBuild), previousBuild > 0,
        let currentBuild = Int(Bundle.buildVersion), currentBuild > 0
    else {
        return
    }

    // reset storage on downgrade
    guard currentBuild > previousBuild else {
        await resetStorage()
        return
    }

    // migrate storage to group
    if previousBuild <= 127 {
        migrateStorageToGroup()
    }

    // migrate archive to /ext
    if previousBuild <= 552 {
        migrateArchive()
    }
}

private func resetStorage() async {
    UserDefaultsStorage.shared.reset()
    try? await FileStorage().reset()
}

func migrateStorageToGroup() {
    guard
        let oldBaseURL = FileManager.default.applicationSupportDirectory,
        let newBaseURL = FileManager.default.groupContainer,
        let contents = try? FileManager.default
            .contentsOfDirectory(atPath: oldBaseURL.path)
    else {
        return
    }

    for path in contents {
        let old = oldBaseURL.appendingPathComponent(path)
        let new = newBaseURL.appendingPathComponent(path)
        try? FileManager.default.moveItem(at: old, to: new)
    }
}

func migrateArchive() {
    guard let rootURL = FileManager.default.groupContainer else { return }

    let mobileURL = rootURL.appendingPathComponent("mobile")
    let oldArchiveURL = mobileURL.appendingPathComponent("any")
    let newArchiveURL = mobileURL.appendingPathComponent("ext")

    try? FileManager.default.moveItem(at: oldArchiveURL, to: newArchiveURL)
}

extension FileManager {
    var applicationSupportDirectory: URL? {
        FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first
    }

    var groupContainer: URL? {
        containerURL(forSecurityApplicationGroupIdentifier: .appGroup)
    }
}

extension UserDefaults {
    static var lastVersion: String {
        "\(lastRelease)(\(lastBuild))"
    }

    static var lastRelease: String {
        get { standard.value(forKey: "version") as? String ?? "" }
        set { standard.set(newValue, forKey: "version") }
    }

    static var lastBuild: String {
        get { standard.value(forKey: "build") as? String ?? "" }
        set { standard.set(newValue, forKey: "build") }
    }
}

public extension Bundle {
    static var fullVersion: String {
        "\(releaseVersion)(\(buildVersion))"
    }

    static var releaseVersion: String {
        main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    static var buildVersion: String {
        main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
}
