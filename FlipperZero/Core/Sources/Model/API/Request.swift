import SwiftProtobuf

public enum Request {
    case ping([UInt8])
    case list(Path)
    case read(Path)
    case write(Path, [UInt8])
    case create(Path, isDirectory: Bool)
    case delete(Path, isForce: Bool)
    case remote(Bool)
    case button(ControlButton)
}

extension Request {
    func serialize() -> PB_Main {
        switch self {
        case .ping(let bytes):
            return .with {
                $0.pingRequest = .with {
                    $0.data = .init(bytes)
                }
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
        case let .delete(path, isForce):
            return .with {
                $0.storageDeleteRequest = .with {
                    $0.path = path.string
                    $0.recursive = isForce
                }
            }
        case let .create(path, isDirectory):
            return .with {
                if isDirectory {
                    $0.storageMkdirRequest = .with {
                        $0.path = path.string
                    }
                } else {
                    $0.storageWriteRequest = .with {
                        $0.path = path.string
                        $0.file.data = .init()
                    }
                }
            }
        case let .remote(start):
            switch start {
            case true:
                return .with {
                    $0.guiStartScreenStreamRequest = .init()
                }
            case false:
                return .with {
                    $0.guiStopScreenStreamRequest = .init()
                }
            }
        case let .button(button):
            return .with {
                $0.guiSendInputEventRequest = .with {
                    switch button {
                    case .up: $0.key = .up
                    case .down: $0.key = .down
                    case .left: $0.key = .left
                    case .right: $0.key = .right
                    case .enter: $0.key = .ok
                    case .back: $0.key = .back
                    }
                }
            }
        }
    }
}

extension PB_Main {
    func serialize() throws -> [UInt8] {
        let stream = OutputByteStream()
        try BinaryDelimited.serialize(message: self, to: stream)
        return stream.bytes
    }
}
