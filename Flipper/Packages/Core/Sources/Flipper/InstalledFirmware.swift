// FIXME: Move somewhere

extension Flipper.DeviceInformation {
    public var firmwareVersion: Update.Version? {
        guard let channel = firmwareChannel else {
            return nil
        }
        let parts = softwareRevision.split(separator: " ")

        var version: String
        switch channel {
        case .release: version = "\(parts[1])"
        case .candidate: version = "\(parts[1])"
        case .development: version = "\(parts[0])"
        case .custom: version = "\(parts[0])"
        }

        return .init(name: version, channel: channel)
    }

    private var firmwareChannel: Update.Channel? {
        let parts = softwareRevision.split(separator: " ")
        guard parts.count >= 2 else { return nil }

        guard !parts[1].hasSuffix("-rc") else {
            return .candidate
        }

        let versionParts = parts[1].split(separator: ".")
        guard
            versionParts.count == 3,
            versionParts.allSatisfy({ $0.allSatisfy { $0.isNumber } })
        else {
            return .development
        }

        return .release
    }
}
