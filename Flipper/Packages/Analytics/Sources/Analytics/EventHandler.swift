public protocol EventHandler {
    func appOpen(target: OpenTarget)

    func flipperGATTInfo(flipperVersion: String)

    func flipperRPCInfo(
        sdcardIsAvailable: Bool,
        internalFreeByte: Int,
        internalTotalByte: Int,
        externalFreeByte: Int,
        externalTotalByte: Int,
        firmwareForkName: String,
        firmwareGitURL: String
    )

    func flipperUpdateStart(
        id: Int,
        from: String,
        to: String
    )

    func flipperUpdateResult(
        id: Int,
        from: String,
        to: String,
        status: UpdateResult
    )

    func synchronizationResult(
        subGHzCount: Int,
        rfidCount: Int,
        nfcCount: Int,
        infraredCount: Int,
        iButtonCount: Int,
        synchronizationTime: Int,
        changesCount: Int
    )

    func subghzProvisioning(
        sim1: String,
        sim2: String,
        ip: String,
        system: String,
        provided: String,
        source: RegionSource
    )

    func debug(info: DebugInfo)
}

public enum OpenTarget: Sendable {
    case app
    case keyImport
    case keyEmulate
    case keyEdit
    case keyShare
    case fileManager
    case remoteControl
    case keyShareURL
    case keyShareUpload
    case keyShareFile
    case nfcDumpEditor
    case saveNFCDump
    case mfKey32
    case fapHub
    case fapHubCategory(String)
    case fapHubSearch
    case fapHubApp(String)
    case fapHubInstall(String)
    case fapHubHide(String)

    public var value: String {
        switch self {
        case .fapHubCategory(let category): return category
        case .fapHubApp(let application): return application
        case .fapHubInstall(let application): return application
        case .fapHubHide(let application): return application
        default: return ""
        }
    }
}

public enum DebugInfo: Sendable {
    case unknownNFCVersion(String)

    public var key: String {
        switch self {
        case .unknownNFCVersion(_): return "nfc_failed_parse"
        }
    }

    public var value: String {
        switch self {
        case .unknownNFCVersion(let value): return value
        }
    }
}

public enum UpdateResult: Sendable {
    case completed
    case canceled
    case failedDownload
    case failedPrepare
    case failedUpload
    case failed
}

public enum RegionSource: Sendable {
    case sim
    case geoIP
    case locale
    case `default`
}
