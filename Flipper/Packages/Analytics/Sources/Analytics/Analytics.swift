public protocol Analytics {
    func appOpen(target: OpenTarget)
    func flipperGATTInfo(flipperVersion: String)
    func flipperRPCInfo(
        sdcardIsAvailable: Bool,
        internalFreeByte: Int,
        internalTotalByte: Int,
        externalFreeByte: Int,
        externalTotalByte: Int
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
        synchronizationTime: Int
    )
    func subghzProvisioning(
        sim1: String,
        sim2: String,
        ip: String,
        system: String,
        provided: String,
        source: RegionSource
    )
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
