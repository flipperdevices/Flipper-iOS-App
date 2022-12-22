import Logging
import Foundation
import SwiftProtobuf

class ClickhouseAnalytics {
    private let logger = Logger(label: "clickhouse-analytics")

    private let host = "https://metric.flipperdevices.com/report"
    private var hostURL: URL { .init(string: host).unsafelyUnwrapped }

    private func report(metric: Metric_MetricReportRequest) {
        #if !DEBUG
        Task {
            do {
                var request = URLRequest(url: hostURL)
                request.httpMethod = "POST"
                request.httpBody = try metric.serializedData()
                _ = try await URLSession.shared.data(for: request)
            } catch {
                logger.error("ch report: \(error)")
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

extension ClickhouseAnalytics: Analytics {
    func appOpen(target: OpenTarget) {
        report(event: .with {
            $0.open = .with {
                $0.target = .init(target)
            }
        })
    }

    func flipperGATTInfo(flipperVersion: String) {
        report(event: .with {
            $0.flipperGattInfo = .with {
                $0.flipperVersion = flipperVersion
            }
        })
    }

    func flipperRPCInfo(
        sdcardIsAvailable: Bool,
        internalFreeByte: Int,
        internalTotalByte: Int,
        externalFreeByte: Int,
        externalTotalByte: Int
    ) {
        report(event: .with {
            $0.flipperRpcInfo = .with {
                $0.sdcardIsAvailable = sdcardIsAvailable
                $0.internalFreeByte = .init(internalFreeByte)
                $0.internalTotalByte = .init(internalTotalByte)
                $0.externalFreeByte = .init(externalFreeByte)
                $0.externalTotalByte = .init(externalTotalByte)
            }
        })
    }

    func flipperUpdateStart(
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

    func flipperUpdateResult(
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

    func syncronizationResult(
        subGHzCount: Int,
        rfidCount: Int,
        nfcCount: Int,
        infraredCount: Int,
        iButtonCount: Int,
        synchronizationTime: Int
    ) {
        report(event: .with {
            $0.synchronizationEnd = .with {
                $0.subghzCount = .init(subGHzCount)
                $0.rfidCount = .init(rfidCount)
                $0.nfcCount = .init(nfcCount)
                $0.infraredCount = .init(infraredCount)
                $0.ibuttonCount = .init(iButtonCount)
                $0.synchronizationTimeMs = .init(synchronizationTime)
            }
        })
    }

    func subghzProvisioning(
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
