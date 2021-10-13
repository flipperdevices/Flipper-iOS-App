class SequencedRequest {
    func split(_ request: Request) -> [PB_Main] {
        switch request {
        // the only request at the moment that can exceed the limit
        case let .write(path, bytes) where bytes.count > Limits.maxPbPacket:
            return splitWriteRequest(path: path, bytes: bytes)
        default:
            return [request.serialize()]
        }
    }

    private func splitWriteRequest(path: Path, bytes: [UInt8]) -> [PB_Main] {
        var requests = [PB_Main]()
        let packetSize = Limits.maxPbPacket
        let packetsCount = (bytes.count - 1) / packetSize + 1
        for index in 0..<packetsCount {
            let startIndex = index * packetSize
            let endIndex = min(startIndex + packetSize, bytes.count)
            let nextBytes = [UInt8](bytes[startIndex..<endIndex])
            let nextMain = Request.write(path, nextBytes)
            requests.append(nextMain.serialize())
        }
        return requests
    }
}
