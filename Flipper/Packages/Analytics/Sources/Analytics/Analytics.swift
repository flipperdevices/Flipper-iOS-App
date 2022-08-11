public protocol Analytics {
    func record(_ event: Event)
}

public extension Analytics {
    func appOpen(target: Event.AppOpen.Target) {
        record(.appOpen(.init(target: target)))
    }

    func flipperGATTInfo(flipperVersion: String) {
        record(.flipperGATTInfo(.init(flipperVersion: flipperVersion)))
    }

    func flipperRPCInfo(
        sdcardIsAvailable: Bool,
        internalFreeByte: Int,
        internalTotalByte: Int,
        externalFreeByte: Int,
        externalTotalByte: Int
    ) {
        record(.flipperRPCInfo(.init(
            sdcardIsAvailable: sdcardIsAvailable,
            internalFreeByte: internalFreeByte,
            internalTotalByte: internalTotalByte,
            externalFreeByte: externalFreeByte,
            externalTotalByte: externalTotalByte)))
    }

    func flipperUpdateStart(
        id: Int,
        from: String,
        to: String
    ) {
        record(.flipperUpdateStart(.init(
            id: id,
            from: from,
            to: to)))
    }

    func flipperUpdateResult(
        id: Int,
        from: String,
        to: String,
        status: Event.UpdateResult.Status
    ) {
        record(.flipperUpdateResult(.init(
            id: id,
            from: from,
            to: to,
            status: status)))
    }

    func syncronizationResult(
        subGHzCount: Int,
        rfidCount: Int,
        nfcCount: Int,
        infraredCount: Int,
        iButtonCount: Int,
        synchronizationTime: Int
    ) {

    }

    func subghzProvisioning(
        sim1: String,
        sim2: String,
        ip: String,
        system: String,
        provided: String,
        source: Event.Provisioning.Source
    ) {
        
    }
}
