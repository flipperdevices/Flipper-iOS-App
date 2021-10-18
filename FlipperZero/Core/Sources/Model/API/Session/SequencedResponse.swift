class SequencedResponse {
    var response: Response?

    func feed(_ main: PB_Main) throws -> Response? {
        // always set response to nil on last part
        defer { if !main.hasNext_p { response = nil } }

        guard main.commandStatus == .ok else {
            print("command error", main.commandStatus)
            return .error(main.commandStatus.rawValue.description)
        }

        guard let content = main.content else {
            return .error("main.content is nil")
        }

        switch main.content {
        case .pingResponse:
            try handlePingResponse()
        case .storageListResponse(let response):
            try handleListResponse(response)
        case .storageReadResponse(let response):
            try handleReadResponse(response)
        case .empty(let response):
            try handleEmptyResponse(response)
        default:
            return .error("unsupported api response: \(content)")
        }

        return main.hasNext_p ? nil : self.response
    }

    func handlePingResponse() throws {
        guard response == nil else {
            throw SequencedResponseError.unexpectedResponse
        }
        response = .ping
    }

    func handleListResponse(_ nextResponse: PBStorage_ListResponse) throws {
        let elements: [Element] = .init(nextResponse.file.map(Element.init))

        switch response {
        case .none:
            self.response = .list(elements)
        case let .some(.list(current)):
            self.response = .list(current + elements)
        default:
            throw SequencedResponseError.unexpectedResponse
        }
    }

    func handleReadResponse(_ nextResponse: PBStorage_ReadResponse) throws {
        let bytes = [UInt8](nextResponse.file.data)

        switch response {
        case .none:
            self.response = .file(bytes)
        case let .some(.file(current)):
            self.response = .file(current + bytes)
        default:
            throw SequencedResponseError.unexpectedResponse
        }
    }

    func handleEmptyResponse(_ response: PB_Empty) throws {
        guard self.response == nil else {
            throw SequencedResponseError.unexpectedResponse
        }
        self.response = .ok
    }
}

enum SequencedResponseError: Error {
    case unexpectedResponse
}
