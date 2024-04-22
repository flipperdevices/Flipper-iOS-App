public enum Content {
    case request(Request)
    case message(OutgoingMessage)
}

extension Content {
    func serialize() -> PB_Main {
        switch self {
        case let .request(request): return request.serialize()
        case let .message(message): return message.serialize()
        }
    }
}
