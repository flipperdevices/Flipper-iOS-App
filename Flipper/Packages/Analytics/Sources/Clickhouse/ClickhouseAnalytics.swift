import Foundation
import SwiftProtobuf

public class ClickhouseAnalytics {
    private let host = "https://metric.flipperdevices.com/report"
    private var hostURL: URL { .init(string: host).unsafelyUnwrapped }

    public init() {}

    private func report(metric: Metric_MetricReportRequest) {
        #if !DEBUG
        Task {
            do {
                var request = URLRequest(url: hostURL)
                request.httpMethod = "POST"
                request.httpBody = try metric.serializedData()
                _ = try await URLSession.shared.data(for: request)
            } catch {
                logger.error("clickhouse: \(error)")
            }
        }
        #endif
    }

    private func report(event: Metric_MetricEventsCollection) {
        report(metric: .with {
            #if DEBUG
            $0.platform = .iosDebug
            #else
            $0.platform = .ios
            #endif
            $0.uuid = DeviceID.uuidString
            $0.sessionUuid = SessionID.uuidString
            $0.events = [event]
        })
    }
}

extension ClickhouseAnalytics: EventHandler {
    public func appOpen(target: OpenTarget) {
        report(event: .with {
            $0.open = .with {
                $0.target = .init(target)
                $0.arg = target.value
            }
        })
    }

    public func flipperGATTInfo(flipperVersion: String) {
        report(event: .with {
            $0.flipperGattInfo = .with {
                $0.flipperVersion = flipperVersion
            }
        })
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
        report(event: .with {
            $0.flipperRpcInfo = .with {
                $0.sdcardIsAvailable = sdcardIsAvailable
                $0.internalFreeByte = .init(internalFreeByte)
                $0.internalTotalByte = .init(internalTotalByte)
                $0.externalFreeByte = .init(externalFreeByte)
                $0.externalTotalByte = .init(externalTotalByte)
                $0.firmwareForkName = firmwareForkName
                $0.firmwareGitURL = firmwareGitURL
            }
        })
    }

    public func flipperUpdateStart(
        id: Int,
        from: String,
        to: String
    ) {
        report(event: .with {
            $0.updateFlipperStart = .with {
                $0.updateID = .init(id)
                $0.updateFrom = from
                $0.updateTo = to
            }
        })
    }

    public func flipperUpdateResult(
        id: Int,
        from: String,
        to: String,
        status: UpdateResult
    ) {
        report(event: .with {
            $0.updateFlipperEnd = .with {
                $0.updateID = .init(id)
                $0.updateFrom = from
                $0.updateTo = to
                $0.updateStatus = .init(status)
            }
        })
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
        report(event: .with {
            $0.synchronizationEnd = .with {
                $0.subghzCount = .init(subGHzCount)
                $0.rfidCount = .init(rfidCount)
                $0.nfcCount = .init(nfcCount)
                $0.infraredCount = .init(infraredCount)
                $0.ibuttonCount = .init(iButtonCount)
                $0.synchronizationTimeMs = .init(synchronizationTime)
                $0.changesCount = .init(changesCount)
            }
        })
    }

    public func subghzProvisioning(
        sim1: String,
        sim2: String,
        ip: String,
        system: String,
        provided: String,
        source: RegionSource
    ) {
        report(event: .with {
            $0.subghzProvisioning = .with {
                $0.regionSim1 = sim1
                $0.regionSim2 = sim2
                $0.regionIp = ip
                $0.regionSystem = system
                $0.regionProvided = provided
                $0.regionSource = .init(source)
            }
        })
    }

    public func debug(info: DebugInfo) {
        report(event: .with {
            $0.debugInfo = .with {
                $0.key = info.key
                $0.value = info.value
            }
        })
    }
}

fileprivate extension Metric_Events_Open.OpenTarget {
    init(_ source: OpenTarget) {
        switch source {
        case .app: self = .app
        case .keyImport: self = .saveKey
        case .keyEmulate: self = .emulate
        case .keyEdit: self = .edit
        case .keyShare: self = .share
        case .fileManager: self = .experimentalFm
        case .remoteControl: self = .experimentalScreenstreaming
        case .keyShareURL: self = .shareShortlink
        case .keyShareUpload: self = .shareLonglink
        case .keyShareFile: self = .shareFile
        case .saveNFCDump: self = .saveDump
        case .mfKey32: self = .mfkey32
        case .nfcDumpEditor: self = .openNfcDumpEditor
        case .fapHub: self = .openFaphub
        case .fapHubCategory: self = .openFaphubCategory
        case .fapHubSearch: self = .openFaphubSearch
        case .fapHubApp: self = .openFaphubApp
        case .fapHubInstall: self = .installFaphubApp
        case .fapHubHide: self = .hideFaphubApp
        }
    }
}

fileprivate extension Metric_Events_UpdateFlipperEnd.UpdateStatus {
    init(_ source: UpdateResult) {
        switch source {
        case .completed: self = .completed
        case .canceled: self = .canceled
        case .failedDownload: self = .failedDownload
        case .failedPrepare: self = .failedPrepare
        case .failedUpload: self = .failedUpload
        case .failed: self = .failed
        }
    }
}

fileprivate extension Metric_Events_SubGhzProvisioning.RegionSource {
    init(_ source: RegionSource) {
        switch source {
        case .sim: self = .simCountry
        case .geoIP: self = .geoIp
        case .locale: self = .system
        case .default: self = .default
        }
    }
}
