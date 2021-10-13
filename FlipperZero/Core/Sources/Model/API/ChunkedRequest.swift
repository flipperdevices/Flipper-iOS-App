class ChunkedRequest {
    func split(_ main: PB_Main) -> [[UInt8]] {
        var result = [[UInt8]]()
        // shouldn't throw
        // swiftlint:disable force_try
        let bytes = try! main.serialize()
        let packetSize = Limits.maxBlePacket
        let packetsCount = (bytes.count - 1) / packetSize + 1
        for index in 0..<packetsCount {
            let startIndex = index * packetSize
            let endIndex = min(startIndex + packetSize, bytes.count)
            let chunk = [UInt8](bytes[startIndex..<endIndex])
            result.append(chunk)
        }
        return result
    }
}
