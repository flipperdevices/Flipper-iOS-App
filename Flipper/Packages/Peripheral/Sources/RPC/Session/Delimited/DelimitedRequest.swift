extension Request {
    func split() -> [Request] {
        switch self {
        // the only request at the moment that can exceed the limit
        case let .storage(.write(path, bytes)):
            return splitWriteRequest(path: path, bytes: bytes)
        default:
            return [self]
        }
    }

    private func splitWriteRequest(path: Path, bytes: [UInt8]) -> [Request] {
        var requests = [Request]()
        bytes.chunk(maxCount: Limits.maxPBStorageFileData).forEach { chunk in
            requests.append(.storage(.write(path, chunk)))
        }
        return requests
    }
}

extension Message {
    func split() -> [Message] {
        return [self]
    }
}
