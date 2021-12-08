import UIKit
import SwiftProtobuf

public enum Response: Equatable {
    case ok
    case error(String)
    case system(System)
    case storage(Storage)

    public enum System: Equatable {
        case ping([UInt8])
    }

    public enum Storage: Equatable {
        case list([Element])
        case file([UInt8])
        case hash(String)
    }
}

extension Response {
    init(decoding content: PB_Main.OneOf_Content) {
        switch content {
        case .empty(let response):
            self.init(decoding: response)
        case .systemPingResponse(let response):
            self.init(decoding: response)
        case .storageListResponse(let response):
            self.init(decoding: response)
        case .storageReadResponse(let response):
            self.init(decoding: response)
        case .storageMd5SumResponse(let response):
            self.init(decoding: response)
        default:
            fatalError("unhandled response")
        }
    }

    init(decoding response: PB_Empty) {
        self = .ok
    }

    init(decoding response: PBSystem_PingResponse) {
        self = .system(.ping(.init(response.data)))
    }

    init(decoding response: PBStorage_ListResponse) {
        self = .storage(.list(.init(response.file.map(Element.init))))
    }

    init(decoding response: PBStorage_ReadResponse) {
        self = .storage(.file(.init(response.file.data)))
    }

    init(decoding response: PBStorage_Md5sumResponse) {
        self = .storage(.hash(response.md5Sum))
    }
}

extension Response {
    func merging(with response: Response) throws -> Response {
        var result = self
        try result.merge(with: response)
        return result
    }

    private mutating func merge(with response: Response) throws {
        switch (self, response) {

        case (.system(var current), .system(let next)):
            try current.merge(with: next)
            self = .system(current)

        case (.storage(var current), .storage(let next)):
            try current.merge(with: next)
            self = .storage(current)

        default:
            throw Error.unexpectedResponse(response)
        }
    }
}

fileprivate extension Response.System {
    mutating func merge(with response: Response.System) throws {
        switch (self, response) {

        case let (.ping(current), .ping(next)):
            self = .ping(current + next)

        default:
            throw Error.unexpectedResponse(.system(response))
        }
    }
}

fileprivate extension Response.Storage {
    mutating func merge(with response: Response.Storage) throws {
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
