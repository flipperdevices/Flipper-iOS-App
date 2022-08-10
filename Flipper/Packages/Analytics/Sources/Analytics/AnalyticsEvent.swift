// swiftlint:disable nesting
public enum Event: Sendable {
    case appOpen(AppOpen)
    case flipperGATTInfo(GATTInfo)
    case flipperRPCInfo(RPCInfo)
    case flipperUpdateStart(UpdateStart)
    case flipperUpdateResult(UpdateResult)
    case syncronizationResult(SyncronizationResult)

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
        let updateFrom: String
        let updateTo: String
        let updateID: Int
    }

    public struct UpdateResult: Sendable {
        let updateFrom: String
        let updateTo: String
        let updateID: Int
        let updateStatus: Int

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
        let synchronizationTimeMS: Int
    }
}
