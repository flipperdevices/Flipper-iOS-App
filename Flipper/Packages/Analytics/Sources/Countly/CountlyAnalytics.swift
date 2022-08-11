import Countly

class CountlyAnalytics: Analytics {
    init() {
        #if !DEBUG
        let config = CountlyConfig()
        config.appKey = "COUNTLY_APP_KEY"
        config.host = "https://countly.flipp.dev/"
        Countly.sharedInstance().start(with: config)
        #endif
    }

    // swiftlint:disable discouraged_optional_collection
    private func recordEvent(key: String, segmentation: [String: String]?) {
        #if !DEBUG
        Countly.sharedInstance().recordEvent(key, segmentation: segmentation)
        #endif
    }

    func appOpen(target: OpenTarget) {
        recordEvent(
            key: "app_open",
            segmentation: [
                "target": String(target.value)
            ])
    }

    func flipperGATTInfo(flipperVersion: String) {
        recordEvent(
            key: "flipper_gatt_info",
            segmentation: [
                "flipper_version": flipperVersion
            ])
    }

    func flipperRPCInfo(
        sdcardIsAvailable: Bool,
        internalFreeByte: Int,
        internalTotalByte: Int,
        externalFreeByte: Int,
        externalTotalByte: Int
    ) {
        recordEvent(
            key: "flipper_rpc_info",
            segmentation: [
                "sdcard_is_available": .init(sdcardIsAvailable),
                "internal_free_byte": .init(internalFreeByte),
                "internal_total_byte": .init(internalTotalByte),
                "external_free_byte": .init(externalFreeByte),
                "external_total_byte": .init(externalTotalByte)
            ])
    }

    func flipperUpdateStart(
        id: Int,
        from: String,
        to: String
    ) {
        recordEvent(
            key: "update_flipper_start",
            segmentation: [
                "update_id": .init(id),
                "update_from": from,
                "update_to": to
            ])
    }

    func flipperUpdateResult(
        id: Int,
        from: String,
        to: String,
        status: UpdateResult
    ) {
        recordEvent(
            key: "update_flipper_end",
            segmentation: [
                "update_id": .init(id),
                "update_from": from,
                "update_to": to,
                "status": .init(status.value)
            ])
    }

    func syncronizationResult(
        subGHzCount: Int,
        rfidCount: Int,
        nfcCount: Int,
        infraredCount: Int,
        iButtonCount: Int,
        synchronizationTime: Int
    ) {
        recordEvent(
            key: "synchronization_end",
            segmentation: [
                "subghz_count": .init(subGHzCount),
                "rfid_count": .init(rfidCount),
                "nfc_count": .init(nfcCount),
                "infrared_count": .init(infraredCount),
                "ibutton_count": .init(iButtonCount),
                "synchronization_time_ms": .init(synchronizationTime)
            ])
    }

    func subghzProvisioning(
        sim1: String,
        sim2: String,
        ip: String,
        system: String,
        provided: String,
        source: RegionSource
    ) {
        recordEvent(
            key: "synchronization_end",
            segmentation: [
                "region_network": "",
                "region_sim_1": sim1,
                "region_sim_2": sim2,
                "region_ip": ip,
                "region_system": system,
                "region_provided": provided,
                "region_source": .init(source.value),
                "is_roaming": "false"
            ])
    }
}

fileprivate extension OpenTarget {
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

fileprivate extension UpdateResult {
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

fileprivate extension RegionSource {
    var value: Int {
        switch self {
        case .sim: return 1
        case .geoIP: return 2
        case .locale: return 3
        case .`default`: return 4
        }
    }
}
