class ChunkedRequest {
    func split(_ main: PB_Main) -> [[UInt8]] {
        // shouldn't throw
        // swiftlint:disable force_try
        let bytes = try! main.serialize()
        return bytes.chunk(maxCount: Limits.maxBlePacket)
    }
}
