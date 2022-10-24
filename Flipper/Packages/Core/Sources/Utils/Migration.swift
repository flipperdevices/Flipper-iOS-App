import Foundation

public func migration() {
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
        resetStorage()
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
        resetStorage()
        return
    }
}

private func resetStorage() {
    UserDefaultsStorage.shared.reset()
    try? FileStorage().reset()
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
