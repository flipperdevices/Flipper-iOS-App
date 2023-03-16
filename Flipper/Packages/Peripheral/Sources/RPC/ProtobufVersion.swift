public struct ProtobufVersion {
    let major: Int
    let minor: Int
    // Unknown / Unsupported
    public static var unknown: ProtobufVersion = .init(major: 0, minor: 0)
    // Initial public version is 0.2
    public static var v0_2: ProtobufVersion = .init(major: 0, minor: 2)
    public static var v0_3: ProtobufVersion = .init(major: 0, minor: 3)
    public static var v0_4: ProtobufVersion = .init(major: 0, minor: 4)
    public static var v0_6: ProtobufVersion = .init(major: 0, minor: 6)
    public static var v1_0: ProtobufVersion = .init(major: 1, minor: 0)
}

extension ProtobufVersion: RawRepresentable {
    public var rawValue: String {
        "\(major).\(minor)"
    }

    public init(rawValue: String) {
        let parts = rawValue.split(separator: ".")
        guard parts.count == 2,
            let major = Int(parts[0]),
            let minor = Int(parts[1])
        else {
            self = .unknown
            return
        }
        self.major = major
        self.minor = minor
    }

    public init(decoding: [UInt8], as: UTF8.Type) {
        self.init(rawValue: .init(decoding: decoding, as: UTF8.self)
            .trimmingCharacters(in: ["\0"]))
    }
}

extension ProtobufVersion: Comparable {
    public static func < (lhs: ProtobufVersion, rhs: ProtobufVersion) -> Bool {
        lhs.major == rhs.major
            ? lhs.minor < rhs.minor
            : lhs.major < rhs.major
    }
}
