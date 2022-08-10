import Countly

actor CountlyAnalytics: Analytics {
    init() {
        let config = CountlyConfig()
        config.appKey = "COUNTLY_APP_KEY"
        config.host = "https://countly.flipp.dev/"
        Countly.sharedInstance().start(with: config)
    }

    func record(_ event: Event) async {
        Countly.sharedInstance().recordEvent(
            event.key,
            segmentation: event.segmentation)
    }
}

fileprivate extension Event {
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

fileprivate extension Event.AppOpen {
    var segmentation: [String: String] {
        [
            "target": "\(target.value)"
        ]
    }
}

fileprivate extension Event.AppOpen.Target {
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

fileprivate extension Event.GATTInfo {
    var segmentation: [String: String] {
        [
            "flipper_version": flipperVersion
        ]
    }
}

fileprivate extension Event.RPCInfo {
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

fileprivate extension Event.UpdateStart {
    var segmentation: [String: String] {
        [
            "update_from": updateFrom,
            "update_to": updateTo,
            "update_id": .init(updateID)
        ]
    }
}

fileprivate extension Event.UpdateResult {
    var segmentation: [String: String] {
        [
            "update_from": updateFrom,
            "update_to": updateTo,
            "update_id": .init(updateID)
        ]
    }
}

fileprivate extension Event.UpdateResult.Status {
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

fileprivate extension Event.SyncronizationResult {
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
