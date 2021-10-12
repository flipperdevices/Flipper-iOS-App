import SwiftProtobuf

public enum Request {
    case ping
    case list(Path)
    case read(Path)
    case write(Path, [UInt8])
    case delete(Path)
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
        case let .list(path):
            return .with {
                $0.storageListRequest = .with {
                    $0.path = path.string
                }
            }
        case let .read(path):
            return .with {
                $0.storageReadRequest = .with {
                    $0.path = path.string
                }
            }
        case let .write(path, bytes):
            return .with {
                $0.storageWriteRequest = .with {
                    $0.path = path.string
                    $0.file.data = .init(bytes)
                }
            }
        case let .delete(path):
            return .with {
                $0.storageDeleteRequest = .with {
                    $0.path = path.string
                }
            }
        }
    }
}
