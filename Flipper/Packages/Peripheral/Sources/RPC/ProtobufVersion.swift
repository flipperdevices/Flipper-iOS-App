public struct ProtobufVersion {
    let major: Int
    let minor: Int

    // Unknown / Unsupported
    public static var unknown: ProtobufVersion = .init(major: 0, minor: 0)

    // Initial public version is 0.2
    public static var v0_2: ProtobufVersion = .init(major: 0, minor: 2)

    // Fixed: BLE disconnection after writing / erasing FLASH
    public static var v0_3: ProtobufVersion = .init(major: 0, minor: 3)

    // System message: UpdateRequest
    // Storage messages: BackupCreateRequest, BackupRestoreRequest
    public static var v0_4: ProtobufVersion = .init(major: 0, minor: 4)

    // System message: PowerInfo
    public static var v0_5: ProtobufVersion = .init(major: 0, minor: 5)

    // App messages:
    // AppExitRequest, AppLoadFileRequest,
    // AppButtonPressRequest, AppButtonReleaseRequest
    public static var v0_6: ProtobufVersion = .init(major: 0, minor: 6)

    // System message:
    // UpdateResponse: passing update preparation detailed status
    public static var v0_7: ProtobufVersion = .init(major: 0, minor: 7)

    // App messages: AppExitRequest, AppLoadFileRequest,
    // AppButtonPressRequest, AppButtonReleaseRequest
    public static var v0_8: ProtobufVersion = .init(major: 0, minor: 8)

    // System message: UpdateResponse, enum UpdateResultCode: new entries
    // OutdatedManifestVersion, IntFull, UnspecifiedError
    public static var v0_9: ProtobufVersion = .init(major: 0, minor: 9)

    // GPIO message:
    // SetPinMode, SetInputPull, GetPinMode, GetPinModeResponse,
    // ReadPin, ReadPinResponse, WritePin
    public static var v0_10: ProtobufVersion = .init(major: 0, minor: 10)

    // App messages:
    // AppStateResponse
    public static var v0_11: ProtobufVersion = .init(major: 0, minor: 11)

    // Region message
    public static var v0_12: ProtobufVersion = .init(major: 0, minor: 12)

    // Storage: timestamp
    public static var v0_13: ProtobufVersion = .init(major: 0, minor: 13)

    // New subsystem: Property
    // Property messages: GetRequest, GetResponse
    // App messages: GetErrorRequest, GetErrorResponse, DataExchangeRequest
    public static var v0_14: ProtobufVersion = .init(major: 0, minor: 14)

    // ScreenFrame: additional orientation field
    public static var v0_15: ProtobufVersion = .init(major: 0, minor: 15)

    // Desktop service api
    public static var v0_16: ProtobufVersion = .init(major: 0, minor: 16)

    // Future release
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
