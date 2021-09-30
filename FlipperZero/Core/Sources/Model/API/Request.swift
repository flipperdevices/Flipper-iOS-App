import SwiftProtobuf

public enum Request {
    case ping
    case list(Directory)
}

extension Request {
    func serialize() throws -> [UInt8] {
        let main: PB_Main = serialize()
        let stream = OutputByteStream()
        try BinaryDelimited.serialize(message: main, to: stream)
        return stream.bytes
    }

    private func serialize() -> PB_Main {
        switch self {
        case .ping:
            return .with {
                $0.pingRequest = .init()
            }
        case .list(let directory):
            return .with {
                $0.storageListRequest = .with {
                    $0.path = "/ext" + directory.name
                }
            }
        }
    }
}
