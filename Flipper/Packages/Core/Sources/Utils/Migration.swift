import Foundation

public func migration() {
    guard UserDefaults.lastVersion != Bundle.fullVersion else {
        return
    }

    if UserDefaults.lastVersion == "()" {
        UserDefaultsStorage.shared.reset()
        try? FileStorage().reset()
    }

    UserDefaults.lastRelease = Bundle.releaseVersion
    UserDefaults.lastBuild = Bundle.buildVersion
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

extension Bundle {
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
