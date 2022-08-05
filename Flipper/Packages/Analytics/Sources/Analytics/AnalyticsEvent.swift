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

extension Event {
    var key: String {
        switch self {
        case .appOpen: return "app_open"
        case .flipperGATTInfo: return "flipper_gatt_info"
        case .flipperRPCInfo: return "flipper_rpc_info"
        case .flipperUpdateStart: return "update_flipper_start"
        case .flipperUpdateResult: return "update_flipper_end"
        case .syncronizationResult: return "synchronization_end"
        }
    }

    var segmentation: [String: String] {
        switch self {
        case .appOpen(let value): return value.segmentation
        case .flipperGATTInfo(let value): return value.segmentation
        case .flipperRPCInfo(let value): return value.segmentation
        case .flipperUpdateStart(let value): return value.segmentation
        case .flipperUpdateResult(let value): return value.segmentation
        case .syncronizationResult(let value): return value.segmentation
        }
    }
}

extension Event.AppOpen {
    var segmentation: [String: String] {
        [
            "target": "\(target.value)"
        ]
    }
}

extension Event.AppOpen.Target {
    var value: Int {
        switch self {
        case .app: return 0
        case .keyImport: return 1
        case .keyEmulate: return 2
        case .keyEdit: return 3
        case .keyShare: return 4
        case .fileManager: return 5
        case .remoteControl: return 6
        }
    }
}

extension Event.GATTInfo {
    var segmentation: [String: String] {
        [
            "flipper_version": flipperVersion
        ]
    }
}

extension Event.RPCInfo {
    var segmentation: [String: String] {
        [
            "sdcard_is_available": .init(sdcardIsAvailable),
            "internal_free_byte": .init(internalFreeByte),
            "internal_total_byte": .init(internalTotalByte),
            "external_free_byte": .init(externalFreeByte),
            "external_total_byte": .init(externalTotalByte)
        ]
    }
}

extension Event.UpdateStart {
    var segmentation: [String: String] {
        [
            "update_from": updateFrom,
            "update_to": updateTo,
            "update_id": .init(updateID)
        ]
    }
}

extension Event.UpdateResult {
    var segmentation: [String: String] {
        [
            "update_from": updateFrom,
            "update_to": updateTo,
            "update_id": .init(updateID)
        ]
    }
}

extension Event.UpdateResult.Status {
    var value: Int {
        switch self {
        case .completed: return 1
        case .canceled: return 2
        case .failedDownload: return 3
        case .failedPrepare: return 4
        case .failedUpload: return 5
        case .failed: return 6
        }
    }
}

extension Event.SyncronizationResult {
    var segmentation: [String: String] {
        [
            "subghz_count": .init(subGHzCount),
            "rfid_count": .init(rfidCount),
            "nfc_count": .init(nfcCount),
            "infrared_count": .init(infraredCount),
            "ibutton_count": .init(iButtonCount),
            "synchronization_time_ms": .init(synchronizationTimeMS)
        ]
    }
}
