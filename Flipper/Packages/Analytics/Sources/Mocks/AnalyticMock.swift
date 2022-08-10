class AnalyticMock: Analytics {
    func appOpen(target: OpenTarget) {
    }

    func flipperGATTInfo(flipperVersion: String) {
    }

    func flipperRPCInfo(
        sdcardIsAvailable: Bool,
        internalFreeByte: Int,
        internalTotalByte: Int,
        externalFreeByte: Int,
        externalTotalByte: Int
    ) {
    }

    func flipperUpdateStart(
        id: Int,
        from: String,
        to: String
    ) {
    }

    func flipperUpdateResult(
        id: Int,
        from: String,
        to: String,
        status: UpdateResult
    ) {
    }

    func syncronizationResult(
        subGHzCount: Int,
        rfidCount: Int,
        nfcCount: Int,
        infraredCount: Int,
        iButtonCount: Int,
        synchronizationTimeMS: Int
    ) {
    }

    func subghzProvisioning(
        sim1: String,
        sim2: String,
        ip: String,
        system: String,
        provided: String,
        source: RegionSource
    ) {
    }
}
