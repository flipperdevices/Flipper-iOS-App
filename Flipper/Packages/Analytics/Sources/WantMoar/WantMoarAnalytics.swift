class WantMoarAnalytics {
    var analytics: [Analytics] = [
        CountlyAnalytics(),
        ClickhouseAnalytics()
    ]
}

extension WantMoarAnalytics: Analytics {
    func appOpen(target: OpenTarget) {
        analytics.forEach {
            $0.appOpen(target: target)
        }
    }

    func flipperGATTInfo(flipperVersion: String) {
        analytics.forEach {
            $0.flipperGATTInfo(flipperVersion: flipperVersion)
        }
    }

    func flipperRPCInfo(
        sdcardIsAvailable: Bool,
        internalFreeByte: Int,
        internalTotalByte: Int,
        externalFreeByte: Int,
        externalTotalByte: Int
    ) {
        analytics.forEach {
            $0.flipperRPCInfo(
                sdcardIsAvailable: sdcardIsAvailable,
                internalFreeByte: internalFreeByte,
                internalTotalByte: internalTotalByte,
                externalFreeByte: externalFreeByte,
                externalTotalByte: externalTotalByte)
        }
    }

    func flipperUpdateStart(
        id: Int,
        from: String,
        to: String
    ) {
        analytics.forEach {
            $0.flipperUpdateStart(id: id, from: from, to: to)
        }
    }

    func flipperUpdateResult(
        id: Int,
        from: String,
        to: String,
        status: UpdateResult
    ) {
        analytics.forEach {
            $0.flipperUpdateResult(id: id, from: from, to: to, status: status)
        }
    }

    func syncronizationResult(
        subGHzCount: Int,
        rfidCount: Int,
        nfcCount: Int,
        infraredCount: Int,
        iButtonCount: Int,
        synchronizationTime: Int
    ) {
        analytics.forEach {
            $0.syncronizationResult(
                subGHzCount: subGHzCount,
                rfidCount: rfidCount,
                nfcCount: nfcCount,
                infraredCount: infraredCount,
                iButtonCount: iButtonCount,
                synchronizationTime: synchronizationTime)
        }
    }

    func subghzProvisioning(
        sim1: String,
        sim2: String,
        ip: String,
        system: String,
        provided: String,
        source: RegionSource
    ) {
        analytics.forEach {
            $0.subghzProvisioning(
                sim1: sim1,
                sim2: sim2,
                ip: ip,
                system: system,
                provided: provided,
                source: source)
        }
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
