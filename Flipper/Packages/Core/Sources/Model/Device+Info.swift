extension Device {
    public struct Info {
        public var hardware: Hardware = .init()
        public var region: Region = .init()
        public var firmware: Firmware = .init()
        public var protobuf: Protobuf = .init()
        public var radio: Radio = .init()
        public var unknown: [String: String] = [:]

        public var keys: [String: String] = [:]

        public struct Hardware {
            public var name: String?
            public var model: String?
            public var region: Region = .init()
            public var version: String?
            public var otp: OTP = .init()
            public var uid: String?

            public struct OTP {
                public var version: String?
            }
        }

        public struct Region {
            public var builtin: String?
            public var provisioned: String?
        }

        public struct Firmware {
            public var branch: Branch = .init()
            public var commit: Commit = .init()
            public var build: Build = .init()
            public var target: String?

            public struct Branch {
                public var name: String?
            }

            public struct Commit {
                public var hash: String?
            }

            public struct Build {
                public var date: String?
            }
        }

        public struct Protobuf {
            public var version: Version = .init()

            public struct Version {
                public var major: String?
                public var minor: String?
            }
        }

        public struct Radio {
            public var stack: Stack = .init()

            public struct Stack {
                public var major: String?
                public var minor: String?
                public var type: String?
                public var sub: String?
            }
        }

        init() {
        }

        init(_ properties: [String: String]) {
            var info = Info()
            for key in properties.keys {
                info.update(key: key, value: properties[key])
            }
            self = info
        }

        mutating func update(key: String, value: String?) {
            defer { keys[key] = value }
            guard let keyPath = keyPath(for: key) else {
                unknown[formatKey(key)] = value
                return
            }
            self[keyPath: keyPath] = value
        }

        func keyPath(for key: String) -> WritableKeyPath<Info, String?>? {
            switch key {
            case "hardware_name", "hardware.name":
                return \.hardware.name
            case "hardware_model", "hardware.model":
                return \.hardware.model
            case "hardware_region", "hardware.region.builtin":
                return \.hardware.region.builtin
            case "hardware_region_provisioned", "hardware.region.provisioned":
                return \.hardware.region.provisioned
            case "hardware_ver", "hardware.ver":
                return \.hardware.version
            case "hardware_otp_ver", "hardware.otp.ver":
                return \.hardware.otp.version
            case "hardware_uid", "hardware.uid":
                return \.hardware.uid
            case "firmware_branch", "firmware.branch.name":
                return \.firmware.branch.name
            case "firmware_commit", "firmware.commit.hash":
                return \.firmware.commit.hash
            case "firmware_build_date", "firmware.build.date":
                return \.firmware.build.date
            case "firmware_target", "firmware.target":
                return \.firmware.target
            case "protobuf_version_major", "protobuf.version.major":
                return \.protobuf.version.major
            case "protobuf_version_minor", "protobuf.version.minor":
                return \.protobuf.version.minor
            case "radio_stack_major", "radio.stack.major":
                return \.radio.stack.major
            case "radio_stack_minor", "radio.stack.minor":
                return \.radio.stack.minor
            case "radio_stack_type", "radio.stack.type":
                return \.radio.stack.type
            case "radio_stack_sub", "radio.stack.sub":
                return \.radio.stack.sub
            default:
                return nil
            }
        }

        private func formatKey(_ key: String) -> String {
            key
                .replacingOccurrences(of: ".", with: " ")
                .replacingOccurrences(of: "_", with: " ")
                .capitalized
                .replacingOccurrences(of: "Ble", with: "BLE")
                .replacingOccurrences(of: "Fus", with: "FUS")
                .replacingOccurrences(of: "Sram", with: "SRAM")
        }
    }
}

extension Device.Info.Firmware {
    public var formatted: String? {
        guard
            let name = branch.name,
            let commit = commit.hash
        else {
            return nil
        }
        return "\(name) \(commit)"
    }
}

extension Device.Info.Protobuf.Version {
    public var formatted: String? {
        guard
            let major = major,
            let minor = minor
        else {
            return nil
        }
        return "\(major).\(minor)"
    }
}

extension Device.Info.Radio.Stack {
    public var formatted: String? {
        guard
            let major = major,
            let minor = minor,
            let type = type
            let sub = sub
        else {
            return nil
        }
        let typeString = RadioStackType(rawValue: type)?.description
        return "\(major).\(minor).\(sub) (\(typeString ?? "Unknown"))"
    }
}

