extension Content {
    func split() -> Queue.Command.Delimited {
        switch self {
        case let .request(request): return .request(request.split())
        case let .message(message): return .message(message.split())
        }
    }
}
