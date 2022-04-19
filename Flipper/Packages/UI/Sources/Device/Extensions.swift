import Core

extension Flipper.DeviceInformation {
    var shortSoftwareVersion: String? {
        guard let channel = firmwareChannel else {
            return nil
        }
        let parts = softwareRevision.split(separator: " ")

        switch channel {
        case .release: return String(parts[1])
        case .canditate: return "RC \(parts[1].dropLast(3))"
        case .development: return "Dev \(parts[0])"
        }
    }

    var firmwareChannel: Update.Channel? {
        let parts = softwareRevision.split(separator: " ")
        guard parts.count >= 2 else { return nil }

        guard !parts[1].hasSuffix("-rc") else {
            return .canditate
        }

        let varsionParts = parts[1].split(separator: ".")
        guard
            varsionParts.count == 3,
            varsionParts.allSatisfy({ $0.allSatisfy { $0.isNumber } })
        else {
            return .development
        }

        return .release
    }
}
