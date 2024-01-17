import Core

extension ArchiveItem {
    public struct InfraredRemote: Equatable {
        public static func == (
            lhs: Core.ArchiveItem.InfraredRemote,
            rhs: Core.ArchiveItem.InfraredRemote
        ) -> Bool {
            lhs.name == rhs.name && lhs.type == rhs.type
        }

        var name: String
        let type: InfraredRemoteType

        public init(name: String, type: InfraredRemoteType) {
            self.name = name
            self.type = type
        }
    }

    public typealias InfraredRemoteRaw = (
        frequency: String,
        dutyCycle: String,
        data: String
    )

    public typealias InfraredRemoteParsed = (
        protocol: String,
        address: String,
        command: String
    )

    public enum InfraredRemoteType: Equatable {
        public static func == (
            lhs: Core.ArchiveItem.InfraredRemoteType,
            rhs: Core.ArchiveItem.InfraredRemoteType
        ) -> Bool {
            switch (lhs, rhs) {
            case let (.raw(lhsRaw), .raw(rhsRaw)):
                return lhsRaw == rhsRaw
            case let (.parsed(lhsParsed), .parsed(rhsParsed)):
                return lhsParsed == rhsParsed
            default:
                return false
            }
        }

        case raw(InfraredRemoteRaw)
        case parsed(InfraredRemoteParsed)
    }

    public var infraredRemotes: [InfraredRemote] {
        get {
            let splitedProperties = splitProperty(by: "name")
            return buildInfraredRemote(from: splitedProperties)
        }
        set {
            self.properties = buildInfraredProperties(by: newValue)
        }
    }

    private var metaKeyProperty: [String] {
        ["Filetype", "Version"]
    }

    private func splitProperty(by key: String) -> [[Property]] {
        var result: [[Property]] = []
        var currentGroup: [Property] = []
        for property in properties {
            if property.key == key {
                if !currentGroup.isEmpty {
                    result.append(currentGroup)
                    currentGroup = []
                }
            }
            if !metaKeyProperty.contains(property.key) {
                currentGroup.append(property)
            }
        }
        if !currentGroup.isEmpty {
            result.append(currentGroup)
        }

        return result
    }

    private func buildInfraredRemote(
        from propertyGroups: [[Property]]
    ) -> [InfraredRemote] {
        var result: [InfraredRemote] = []

        for group in propertyGroups {
            guard
                let name = group["name"],
                let type = group["type"]
            else { continue }

            switch type {
            case "raw":
                guard
                    let frequency = group["frequency"],
                    let dutyCycle = group["duty_cycle"],
                    let data = group["data"]
                else { continue }

                let raw = (
                    frequency: frequency,
                    dutyCycle: dutyCycle,
                    data: data
                )
                let remote = InfraredRemote(name: name, type: .raw(raw))

                result.append(remote)
            case "parsed":
                guard
                    let proto = group["protocol"],
                    let address = group["address"],
                    let command = group["command"]
                else { continue }

                let parsed = (
                    protocol: proto,
                    address: address,
                    command: command
                )
                let remote = InfraredRemote(name: name, type: .parsed(parsed))

                result.append(remote)
            default: continue
            }
        }

        return result
    }

    private func buildInfraredProperties(
        by remotes: [InfraredRemote]
    ) -> [Property] {
        var result: [Property] = [
            Property(key: "Filetype", value: "IR signals file"),
            Property(key: "Version", value: "1")
        ]

        for remote in remotes {
            result.append(Property(key: "name", value: remote.name))

            switch remote.type {
            case .raw(let raw):
                let remoteProperties = [
                    Property(key: "type", value: "raw"),
                    Property(key: "frequency", value: raw.frequency),
                    Property(key: "duty_cycle", value: raw.dutyCycle),
                    Property(key: "data", value: raw.data)
                ]
                result += remoteProperties
            case .parsed(let parsed):
                let remoteProperties = [
                    Property(key: "type", value: "parsed"),
                    Property(key: "protocol", value: parsed.protocol),
                    Property(key: "address", value: parsed.address),
                    Property(key: "command", value: parsed.command)
                ]
                result += remoteProperties
            }
        }
        return result
    }
}
