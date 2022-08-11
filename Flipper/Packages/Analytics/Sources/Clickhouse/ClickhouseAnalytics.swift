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

// swiftlint:disable function_body_length
extension ClickhouseAnalytics: Analytics {
    func record(_ event: Event) {
        switch event {
        case .appOpen(let appOpen):
            report(event: .with {
                $0.open = .with {
                    $0.target = .init(appOpen.target)
                }
            })
        case .flipperGATTInfo(let gattInfo):
            report(event: .with {
                $0.flipperGattInfo = .with {
                    $0.flipperVersion = gattInfo.flipperVersion
                }
            })
        case .flipperRPCInfo(let rpcInfo):
            report(event: .with {
                $0.flipperRpcInfo = .with {
                    $0.sdcardIsAvailable = rpcInfo.sdcardIsAvailable
                    $0.internalFreeByte = .init(rpcInfo.internalFreeByte)
                    $0.internalTotalByte = .init(rpcInfo.internalTotalByte)
                    $0.externalFreeByte = .init(rpcInfo.externalFreeByte)
                    $0.externalTotalByte = .init(rpcInfo.externalTotalByte)
                }
            })
        case .flipperUpdateStart(let updateStart):
            report(event: .with {
                $0.updateFlipperStart = .with {
                    $0.updateID = .init(updateStart.id)
                    $0.updateFrom = updateStart.from
                    $0.updateTo = updateStart.to
                }
            })
        case .flipperUpdateResult(let updateResult):
            report(event: .with {
                $0.updateFlipperEnd = .with {
                    $0.updateID = .init(updateResult.id)
                    $0.updateFrom = updateResult.from
                    $0.updateTo = updateResult.to
                    $0.updateStatus = .init(updateResult.status)
                }
            })
        case .syncronizationResult(let result):
            report(event: .with {
                $0.synchronizationEnd = .with {
                    $0.subghzCount = .init(result.subGHzCount)
                    $0.rfidCount = .init(result.rfidCount)
                    $0.nfcCount = .init(result.nfcCount)
                    $0.infraredCount = .init(result.infraredCount)
                    $0.ibuttonCount = .init(result.iButtonCount)
                    $0.synchronizationTimeMs = .init(result.synchronizationTime)
                }
            })
        case .provisioning(let provisioning):
            report(event: .with {
                $0.subghzProvisioning = .with {
                    $0.regionSim1 = provisioning.sim1
                    $0.regionSim2 = provisioning.sim2
                    $0.regionIp = provisioning.ip
                    $0.regionSystem = provisioning.system
                    $0.regionProvided = provisioning.provided
                    $0.regionSource = .init(provisioning.source)
                }
            })
        }
    }
}

fileprivate extension Metric_Events_Open.OpenTarget {
    init(_ source: Event.AppOpen.Target) {
        switch source {
        case .app: self = .app
        case .keyImport: self = .saveKey
        case .keyEmulate: self = .emulate
        case .keyEdit: self = .edit
        case .keyShare: self = .share
        case .fileManager: self = .experimentalFm
        case .remoteControl: self = .experimentalScreenstreaming
        }
    }
}

fileprivate extension Metric_Events_UpdateFlipperEnd.UpdateStatus {
    init(_ source: Event.UpdateResult.Status) {
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
    init(_ source: Event.Provisioning.Source) {
        switch source {
        case .sim: self = .simCountry
        case .geoIP: self = .geoIp
        case .locale: self = .system
        case .default: self = .default
        }
    }
}
