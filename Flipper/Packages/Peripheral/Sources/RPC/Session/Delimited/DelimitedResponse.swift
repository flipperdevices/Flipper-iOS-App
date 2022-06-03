extension Response {
    func appending(contentsOf response: Response) throws -> Response {
        var result = self
        try result.append(contentsOf: response)
        return result
    }

    mutating func append(contentsOf response: Response) throws {
        switch (self, response) {

        case (.system(var current), .system(let next)):
            try current.append(contentsOf: next)
            self = .system(current)

        case (.storage(var current), .storage(let next)):
            try current.append(contentsOf: next)
            self = .storage(current)

        default:
            throw Error.unexpectedResponse(response)
        }
    }
}

fileprivate extension Response.System {
    mutating func append(contentsOf response: Response.System) throws {
        switch (self, response) {

        case let (.ping(current), .ping(next)):
            self = .ping(current + next)

        default:
            throw Error.unexpectedResponse(.system(response))
        }
    }
}

fileprivate extension Response.Storage {
    mutating func append(contentsOf response: Response.Storage) throws {
        switch (self, response) {

        case let (.list(current), .list(next)):
            self = .list(current + next)

        case let (.file(current), .file(next)):
            self = .file(current + next)

        default:
            throw Error.unexpectedResponse(.storage(response))
        }
    }
}
