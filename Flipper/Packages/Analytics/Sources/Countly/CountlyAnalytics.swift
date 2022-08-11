import Countly
import Logging

class CountlyAnalytics {
    private let logger = Logger(label: "countly-analytics")

    private let hostURL = "https://countly.flipp.dev/"

    init() {
        #if !DEBUG
        guard let appKey = Bundle
            .main
            .object(forInfoDictionaryKey: "COUNTLY_APP_KEY") as? String
        else {
            logger.error("COUNTLY_APP_KEY not found")
            return
        }
        let config = CountlyConfig()
        config.appKey = appKey
        config.deviceID = DeviceID.uuidString
        config.host = hostURL
        Countly.sharedInstance().start(with: config)
        #endif
    }

    // swiftlint:disable discouraged_optional_collection
    private func recordEvent(key: String, segmentation: [String: String]?) {
        #if !DEBUG
        Countly.sharedInstance().recordEvent(key, segmentation: segmentation)
        #endif
    }
}

extension CountlyAnalytics: Analytics {
    func record(_ event: Event) {
        switch event {
        case .appOpen(let event):
            recordEvent(
                key: "app_open",
                segmentation: [
                    "target": String(event.target.value)
                ])
        case .flipperGATTInfo(let event):
            recordEvent(
                key: "flipper_gatt_info",
                segmentation: [
                    "flipper_version": event.flipperVersion
                ])
        case .flipperRPCInfo(let event):
            recordEvent(
                key: "flipper_rpc_info",
                segmentation: [
                    "sdcard_is_available": .init(event.sdcardIsAvailable),
                    "internal_free_byte": .init(event.internalFreeByte),
                    "internal_total_byte": .init(event.internalTotalByte),
                    "external_free_byte": .init(event.externalFreeByte),
                    "external_total_byte": .init(event.externalTotalByte)
                ])
        case .flipperUpdateStart(let event):
            recordEvent(
                key: "update_flipper_start",
                segmentation: [
                    "update_id": .init(event.id),
                    "update_from": event.from,
                    "update_to": event.to
                ])
        case .flipperUpdateResult(let event):
            recordEvent(
                key: "update_flipper_end",
                segmentation: [
                    "update_id": .init(event.id),
                    "update_from": event.from,
                    "update_to": event.to,
                    "status": .init(event.status.value)
                ])
        case .syncronizationResult(let event):
            recordEvent(
                key: "synchronization_end",
                segmentation: [
                    "subghz_count": .init(event.subGHzCount),
                    "rfid_count": .init(event.rfidCount),
                    "nfc_count": .init(event.nfcCount),
                    "infrared_count": .init(event.infraredCount),
                    "ibutton_count": .init(event.iButtonCount),
                    "synchronization_time_ms": .init(event.synchronizationTime)
                ])
        case .provisioning(let event):
            recordEvent(
                key: "synchronization_end",
                segmentation: [
                    "region_network": "",
                    "region_sim_1": event.sim1,
                    "region_sim_2": event.sim2,
                    "region_ip": event.ip,
                    "region_system": event.system,
                    "region_provided": event.provided,
                    "region_source": .init(event.source.value),
                    "is_roaming": "false"
                ])
        }
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

fileprivate extension Event.Provisioning.Source {
    var value: Int {
        switch self {
        case .sim: return 1
        case .geoIP: return 2
        case .locale: return 3
        case .`default`: return 4
        }
    }
}
