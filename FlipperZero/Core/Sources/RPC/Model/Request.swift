import SwiftProtobuf

public enum Request {
    case ping([UInt8])
    case list(Path)
    case read(Path)
    case write(Path, [UInt8])
    case create(Path, isDirectory: Bool)
    case delete(Path, isForce: Bool)
    case hash(Path)
    case remote(Bool)
    case button(InputKey, InputType)
}

// swiftlint:disable function_body_length cyclomatic_complexity

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
        case let .hash(path):
            return .with {
                $0.storageMd5SumRequest = .with {
                    $0.path = path.string
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
        case let .button(key, type):
            return .with {
                $0.guiSendInputEventRequest = .with {
                    $0.key = .init(key)
                    $0.type = .init(type)
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

extension PBGui_InputKey {
    init(_ source: InputKey) {
        switch source {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .enter: self = .ok
        case .back: self = .back
        }
    }
}

extension PBGui_InputType {
    init(_ source: InputType) {
        switch source {
        case .press: self = .press
        case .release: self = .release
        case .short: self = .short
        case .long: self = .long
        case .repeat: self = .repeat
        }
    }
}
