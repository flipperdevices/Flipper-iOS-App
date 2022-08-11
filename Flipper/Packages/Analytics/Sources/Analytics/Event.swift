// swiftlint:disable nesting
public enum Event: Sendable {
    case appOpen(AppOpen)
    case flipperGATTInfo(GATTInfo)
    case flipperRPCInfo(RPCInfo)
    case flipperUpdateStart(UpdateStart)
    case flipperUpdateResult(UpdateResult)
    case syncronizationResult(SyncronizationResult)
    case provisioning(Provisioning)

    public struct AppOpen: Sendable {
        let target: Target

        public enum Target: Sendable {
            case app
            case keyImport
            case keyEmulate
            case keyEdit
            case keyShare
            case fileManager
            case remoteControl
        }

        public init(target: Target) {
            self.target = target
        }
    }

    public struct GATTInfo: Sendable {
        let flipperVersion: String

        public init(flipperVersion: String) {
            self.flipperVersion = flipperVersion
        }
    }

    public struct RPCInfo: Sendable {
        let sdcardIsAvailable: Bool
        let internalFreeByte: Int
        let internalTotalByte: Int
        let externalFreeByte: Int
        let externalTotalByte: Int

        public init(
            sdcardIsAvailable: Bool,
            internalFreeByte: Int,
            internalTotalByte: Int,
            externalFreeByte: Int,
            externalTotalByte: Int
        ) {
            self.sdcardIsAvailable = sdcardIsAvailable
            self.internalFreeByte = internalFreeByte
            self.internalTotalByte = internalTotalByte
            self.externalFreeByte = externalFreeByte
            self.externalTotalByte = externalTotalByte
        }
    }

    public struct UpdateStart: Sendable {
        let id: Int
        let from: String
        let to: String
    }

    public struct UpdateResult: Sendable {
        let id: Int
        let from: String
        let to: String
        let status: Status

        public enum Status: Sendable {
            case completed
            case canceled
            case failedDownload
            case failedPrepare
            case failedUpload
            case failed
        }
    }

    public struct SyncronizationResult: Sendable {
        let subGHzCount: Int
        let rfidCount: Int
        let nfcCount: Int
        let infraredCount: Int
        let iButtonCount: Int
        let synchronizationTime: Int
    }

    public struct Provisioning: Sendable {
        let sim1: String
        let sim2: String
        let ip: String
        let system: String
        let provided: String
        let source: Source

        public enum Source: Sendable {
            case sim
            case geoIP
            case locale
            case `default`
        }
    }
}
