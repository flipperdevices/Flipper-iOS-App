import Countly

public class CountlyAnalytics {
    private let hostURL = "https://countly.flipp.dev/"

    public init() {
        #if !DEBUG
        guard let appKey = Bundle
            .main
            .object(forInfoDictionaryKey: "COUNTLY_APP_KEY") as? String
        else {
            logger.error("countly: COUNTLY_APP_KEY not found")
            return
        }
        let config = CountlyConfig()
        config.appKey = appKey
        config.deviceID = DeviceID.uuidString
        config.host = hostURL
        Countly.sharedInstance().start(with: config)
        #endif
    }

    private func recordEvent(key: String, segmentation: [String: String]?) {
        #if !DEBUG
        Countly.sharedInstance().recordEvent(key, segmentation: segmentation)
        #endif
    }
}

extension CountlyAnalytics: EventHandler {
    public func appOpen(target: OpenTarget) {
        recordEvent(
            key: "app_open",
            segmentation: [
                "target": String(target.value)
            ])
    }

    public func flipperGATTInfo(flipperVersion: String) {
        recordEvent(
            key: "flipper_gatt_info",
            segmentation: [
                "flipper_version": flipperVersion
            ])
    }

    public func flipperRPCInfo(
        sdcardIsAvailable: Bool,
        internalFreeByte: Int,
        internalTotalByte: Int,
        externalFreeByte: Int,
        externalTotalByte: Int,
        firmwareForkName: String,
        firmwareGitURL: String
    ) {
        recordEvent(
            key: "flipper_rpc_info",
            segmentation: [
                "sdcard_is_available": .init(sdcardIsAvailable),
                "internal_free_byte": .init(internalFreeByte),
                "internal_total_byte": .init(internalTotalByte),
                "external_free_byte": .init(externalFreeByte),
                "external_total_byte": .init(externalTotalByte),
                "firmware_fork_name": firmwareForkName,
                "firmware_git_url": firmwareGitURL
            ])
    }

    public func flipperUpdateStart(
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

    public func flipperUpdateResult(
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

    public func synchronizationResult(
        subGHzCount: Int,
        rfidCount: Int,
        nfcCount: Int,
        infraredCount: Int,
        iButtonCount: Int,
        synchronizationTime: Int,
        changesCount: Int
    ) {
        recordEvent(
            key: "synchronization_end",
            segmentation: [
                "subghz_count": .init(subGHzCount),
                "rfid_count": .init(rfidCount),
                "nfc_count": .init(nfcCount),
                "infrared_count": .init(infraredCount),
                "ibutton_count": .init(iButtonCount),
                "synchronization_time_ms": .init(synchronizationTime),
                "changes_count": .init(changesCount)
            ])
    }

    public func subghzProvisioning(
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
        case .keyShareURL: return 7
        case .keyShareUpload: return 8
        case .keyShareFile: return 9
        case .saveNFCDump: return 10
        case .mfKey32: return 11
        case .nfcDumpEditor: return 12
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
