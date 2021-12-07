class DelimitedResponse {
    var response: Response?

    func feed(_ main: PB_Main) throws -> Result<Response, Error>? {
        // always set response to nil on last part
        defer { if !main.hasNext_p { response = nil } }

        guard main.commandStatus == .ok else {
            return .failure(.init(main.commandStatus))
        }

        switch main.content {
        case .systemPingResponse(let response):
            try handlePingResponse(response)
        case .storageListResponse(let response):
            try handleListResponse(response)
        case .storageReadResponse(let response):
            try handleReadResponse(response)
        case .storageMd5SumResponse(let response):
            try handleHashResponse(response)
        case .empty(let response):
            try handleEmptyResponse(response)
        default:
            return .failure(.init(main.commandStatus))
        }

        guard main.hasNext_p == false, let response = response else {
            return nil
        }

        return .success(response)
    }

    func handlePingResponse(_ nextResponse: PBSystem_PingResponse) throws {
        switch response {
        case .none:
            self.response = .system(.ping(.init(nextResponse.data)))
        default:
            throw SequencedResponseError.unexpectedResponse
        }
    }

    func handleListResponse(_ nextResponse: PBStorage_ListResponse) throws {
        let elements: [Element] = .init(nextResponse.file.map(Element.init))

        switch response {
        case .none:
            self.response = .storage(.list(elements))
        case let .some(.storage(.list(current))):
            self.response = .storage(.list(current + elements))
        default:
            throw SequencedResponseError.unexpectedResponse
        }
    }

    func handleReadResponse(_ nextResponse: PBStorage_ReadResponse) throws {
        let bytes = [UInt8](nextResponse.file.data)

        switch response {
        case .none:
            self.response = .storage(.file(bytes))
        case let .some(.storage(.file(current))):
            self.response = .storage(.file(current + bytes))
        default:
            throw SequencedResponseError.unexpectedResponse
        }
    }

    func handleHashResponse(_ nextResponse: PBStorage_Md5sumResponse) throws {
        self.response = .storage(.hash(nextResponse.md5Sum))
    }

    func handleEmptyResponse(_ response: PB_Empty) throws {
        guard self.response == nil else {
            throw SequencedResponseError.unexpectedResponse
        }
        self.response = .ok
    }
}

enum SequencedResponseError: Swift.Error {
    case unexpectedResponse
}
