class WantMoarEventHandler {
    var handlers: [EventHandler]

    init(handlers: [EventHandler]) {
        self.handlers = handlers
    }
}

extension WantMoarEventHandler: EventHandler {
    func appOpen(target: OpenTarget) {
        handlers.forEach {
            $0.appOpen(target: target)
        }
    }

    func flipperGATTInfo(flipperVersion: String) {
        handlers.forEach {
            $0.flipperGATTInfo(flipperVersion: flipperVersion)
        }
    }

    func flipperRPCInfo(
        sdcardIsAvailable: Bool,
        internalFreeByte: Int,
        internalTotalByte: Int,
        externalFreeByte: Int,
        externalTotalByte: Int,
        firmwareForkName: String,
        firmwareGitURL: String
    ) {
        handlers.forEach {
            $0.flipperRPCInfo(
                sdcardIsAvailable: sdcardIsAvailable,
                internalFreeByte: internalFreeByte,
                internalTotalByte: internalTotalByte,
                externalFreeByte: externalFreeByte,
                externalTotalByte: externalTotalByte,
                firmwareForkName: firmwareForkName,
                firmwareGitURL: firmwareGitURL
            )
        }
    }

    func flipperUpdateStart(
        id: Int,
        from: String,
        to: String
    ) {
        handlers.forEach {
            $0.flipperUpdateStart(id: id, from: from, to: to)
        }
    }

    func flipperUpdateResult(
        id: Int,
        from: String,
        to: String,
        status: UpdateResult
    ) {
        handlers.forEach {
            $0.flipperUpdateResult(id: id, from: from, to: to, status: status)
        }
    }

    func synchronizationResult(
        subGHzCount: Int,
        rfidCount: Int,
        nfcCount: Int,
        infraredCount: Int,
        iButtonCount: Int,
        synchronizationTime: Int,
        changesCount: Int
    ) {
        handlers.forEach {
            $0.synchronizationResult(
                subGHzCount: subGHzCount,
                rfidCount: rfidCount,
                nfcCount: nfcCount,
                infraredCount: infraredCount,
                iButtonCount: iButtonCount,
                synchronizationTime: synchronizationTime,
                changesCount: changesCount)
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
        handlers.forEach {
            $0.subghzProvisioning(
                sim1: sim1,
                sim2: sim2,
                ip: ip,
                system: system,
                provided: provided,
                source: source)
        }
    }

    func debug(info: DebugInfo) {
        handlers.forEach {
            $0.debug(info: info)
        }
    }
}
