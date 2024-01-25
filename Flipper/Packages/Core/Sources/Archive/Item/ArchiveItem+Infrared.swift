extension ArchiveItem {
    public struct InfraredRemote: Equatable {
        public var name: String
        public let type: RemoteType

        public enum RemoteType: Equatable {
            case raw(Raw)
            case parsed(Parsed)

            public struct Raw: Equatable {
                let frequency: String
                let dutyCycle: String
                let data: String
            }

            public struct Parsed: Equatable {
                let `protocol`: String
                let address: String
                let command: String
            }
        }
    }

    public var infraredRemotes: [InfraredRemote] {
        get { buildInfraredRemotes(from: splitProperty(by: "name")) }
        set { properties = buildInfraredProperties(by: newValue) }
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

    private func buildInfraredRemotes(
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

                let remote = InfraredRemote(name: name, type: .raw(.init(
                    frequency: frequency,
                    dutyCycle: dutyCycle,
                    data: data
                )))

                result.append(remote)
            case "parsed":
                guard
                    let proto = group["protocol"],
                    let address = group["address"],
                    let command = group["command"]
                else { continue }

                let remote = InfraredRemote(name: name, type: .parsed(.init(
                    protocol: proto,
                    address: address,
                    command: command
                )))

                result.append(remote)
            default:
                continue
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
                result.append(contentsOf: [
                    Property(key: "type", value: "raw"),
                    Property(key: "frequency", value: raw.frequency),
                    Property(key: "duty_cycle", value: raw.dutyCycle),
                    Property(key: "data", value: raw.data)
                ])
            case .parsed(let parsed):
                result.append(contentsOf: [
                    Property(key: "type", value: "parsed"),
                    Property(key: "protocol", value: parsed.protocol),
                    Property(key: "address", value: parsed.address),
                    Property(key: "command", value: parsed.command)
                ])
            }
        }

        return result
    }

    public var getInfraredRemoteNames: [String] {
        return infraredRemotes.map { $0.name }
    }
}
