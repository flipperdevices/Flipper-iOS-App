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
        bytes.chunk(maxCount: Limits.maxPbPacket).forEach { chunk in
            let nextRequest = Request.write(path, chunk)
            var nextMain = nextRequest.serialize()
            nextMain.hasNext_p = true
            requests.append(nextMain)
        }
        if var last = requests.popLast() {
            last.hasNext_p = false
            requests.append(last)
        }
        return requests
    }
}
