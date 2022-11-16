import Core
import Inject
import Combine
import Peripheral
import Foundation
import Collections
import Logging

@MainActor
class DeviceInfoViewModel: ObservableObject {
    private let logger = Logger(label: "device-info-vm")

    @Inject private var rpc: RPC
    @Inject private var appState: AppState
    var disposeBag = DisposeBag()

    @Published var flipper: Flipper?
    @Published var deviceInfo: [String: String] = [:]
    @Published var powerInfo: [String: String] = [:]
    @Published var isReady = false

    enum RadioStackType: String, CustomStringConvertible {
        case bleFull = "1"
        case bleLight = "3"
        case bleBeacon = "4"
        case bleBasic = "5"
        case bleFullExtAdv = "6"
        case bleHCIExtAdv = "7"

        var description: String {
            switch self {
            case .bleFull: return "Full"
            case .bleLight: return "Light"
            case .bleBeacon: return "Beacon"
            case .bleBasic: return "Basic"
            case .bleFullExtAdv: return "Full Ext Adv"
            case .bleHCIExtAdv: return "HCI Ext Adv"
            }
        }
    }

    var deviceName: String {
        deviceInfo["hardware_name"] ?? ""
    }
    var hardwareModel: String {
        deviceInfo["hardware_model"] ?? ""
    }
    var hardwareRegion: String {
        deviceInfo["hardware_region"] ?? ""
    }
    var hardwareRegionProvisioned: String {
        deviceInfo["hardware_region_provisioned"] ?? ""
    }

    var hardwareVersion: String { deviceInfo["hardware_ver"] ?? "" }
    var hardwareOTPVersion: String { deviceInfo["hardware_otp_ver"] ?? "" }
    var serialNumber: String { deviceInfo["hardware_uid"] ?? "" }

    var softwareRevision: String { deviceInfo["firmware_commit"] ?? "" }
    var buildDate: String { deviceInfo["firmware_build_date"] ?? "" }
    var firmwareTarget: String { deviceInfo["firmware_target"] ?? "" }
    var protobufVersion: String {
        guard
            let major = deviceInfo["protobuf_version_major"],
            let minor = deviceInfo["protobuf_version_minor"]
        else {
            return ""
        }
        return "\(major).\(minor)"
    }

    var radioFirmware: String {
        guard
            let major = deviceInfo["radio_stack_major"],
            let minor = deviceInfo["radio_stack_minor"],
            let type = deviceInfo["radio_stack_type"]
        else {
            return ""
        }
        let typeString = RadioStackType(rawValue: type)?.description
            ?? "Unknown"
        return "\(major).\(minor).\(type) (\(typeString))"
    }

    private var usedKeys: [String] = [
        "hardware_name",
        "hardware_model",
        "hardware_region",
        "hardware_region_provisioned",
        "hardware_ver",
        "hardware_otp_ver",
        "hardware_uid",
        "firmware_commit",
        "firmware_build_date",
        "firmware_target",
        "protobuf_version_major",
        "protobuf_version_minor",
        "radio_stack_major",
        "radio_stack_minor",
        "radio_stack_type"
    ]

    private func formatKey(_ key: String) -> String {
        key
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
            .replacingOccurrences(of: "Ble", with: "BLE")
            .replacingOccurrences(of: "Fus", with: "FUS")
            .replacingOccurrences(of: "Sram", with: "SRAM")
    }

    var otherKeys: OrderedDictionary<String, String> {
        var result: OrderedDictionary<String, String> = .init()

        let keys = deviceInfo.keys
            .filter { !usedKeys.contains($0) }
            .sorted()

        for key in keys {
            result[formatKey(key)] = deviceInfo[key]
        }

        return result
    }

    init() {
        appState.$flipper
            .receive(on: DispatchQueue.main)
            .assign(to: \.flipper, on: self)
            .store(in: &disposeBag)
    }

    func getInfo() async {
        await getDeviceInfo()
        await getPowerInfo()
        isReady = true
    }

    func getDeviceInfo() async {
        do {
            for try await (key, value) in rpc.deviceInfo() {
                deviceInfo[key] = value
            }
        } catch {
            logger.error("device info: \(error)")
        }
    }

    func getPowerInfo() async {
        do {
            for try await (key, value) in rpc.powerInfo() {
                powerInfo[key] = value
            }
        } catch {
            logger.error("power info: \(error)")
        }
    }

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        return formatter
    }()

    func share() {
        var array = deviceInfo.toArray().sorted()
        array += powerInfo.toArray().sorted()

        if let int = flipper?.storage?.internal {
            array.append("int_available: \(int.free)")
            array.append("int_total: \(int.total)")
        }
        if let ext = flipper?.storage?.external {
            array.append("ext_available: \(ext.free)")
            array.append("ext_total: \(ext.total)")
        }

        let name = flipper?.name ?? "unknown"
        let content = array.joined(separator: "\n")
        let filenname = "dump-\(name)-\(formatter.string(from: Date())).txt"

        Core.share(content, filename: filenname)
    }
}

private extension Dictionary where Key == String, Value == String {
    func toArray() -> [String] {
        self.map { "\($0): \($1)" }
    }
}
