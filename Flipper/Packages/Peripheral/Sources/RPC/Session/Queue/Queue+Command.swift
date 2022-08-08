extension Queue {
    public typealias OutputContinuation = AsyncThrowingStream<Content, Swift.Error>.Continuation
    public typealias InputContinuation = AsyncThrowingStream<Response, Swift.Error>.Continuation

    struct Command {
        let id: Int
        var content: Content
        var delimited: Delimited
        let outputContinuation: OutputContinuation
        let inputContinuation: InputContinuation

        init(
            id: Int,
            content: Content,
            outputContinuation: OutputContinuation,
            inputContinuation: InputContinuation
        ) {
            self.id = id
            self.content = content
            self.delimited = content.split()
            self.outputContinuation = outputContinuation
            self.inputContinuation = inputContinuation
        }

        enum Delimited {
            case request([Request])
            case message([Message])
        }
    }
}

extension Queue.Command.Delimited {
    var isEmpty: Bool {
        switch self {
        case let .request(parts): return parts.isEmpty
        case let .message(parts): return parts.isEmpty
        }
    }

    mutating func drain() -> Content? {
        let content: Content?
        switch self {
        case var .request(parts) where !parts.isEmpty:
            content = .request(parts.removeFirst())
            self = .request(parts)
        case var .message(parts) where !parts.isEmpty:
            content = .message(parts.removeFirst())
            self = .message(parts)
        default:
            content = nil
        }
        return content
    }
}
