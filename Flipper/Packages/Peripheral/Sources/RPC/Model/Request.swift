import SwiftProtobuf
import struct Foundation.Date

// swiftlint:disable function_body_length

public enum Request {
    case system(System)
    case storage(Storage)
    case gui(GUI)

    public enum System {
        case info
        case alert
        case ping([UInt8])
        case getDate
        case setDate(Date)
        case update(String)
    }

    public enum Storage {
        case info(Path)
        case list(Path)
        case read(Path)
        case write(Path, [UInt8])
        case create(Path, isDirectory: Bool)
        case delete(Path, isForce: Bool)
        case move(Path, Path)
        case hash(Path)
    }

    public enum GUI {
        case screenStream(Bool)
        case virtualDisplay(Bool)
        case button(InputKey, InputType)
    }
}

extension Request {
    func serialize() -> PB_Main {
        switch self {
        case .system(let request): return request.serialize()
        case .storage(let request): return request.serialize()
        case .gui(let request): return request.serialize()
        }
    }
}

extension Request.System {
    func serialize() -> PB_Main {
        switch self {
        case .info:
            return .with {
                $0.systemDeviceInfoRequest = .init()
            }
        case .alert:
            return .with {
                $0.systemPlayAudiovisualAlertRequest = .init()
            }
        case .ping(let bytes):
            return .with {
                $0.systemPingRequest = .with {
                    $0.data = .init(bytes)
                }
            }
        case .getDate:
            return .with {
                $0.systemGetDatetimeRequest = .init()
            }
        case .setDate(let date):
            return .with {
                $0.systemSetDatetimeRequest = .with {
                    $0.datetime = date.dateTime
                }
            }
        case .update(let manifest):
            return .with {
                $0.systemUpdateRequest = .with {
                    $0.updateManifest = manifest
                }
            }
        }
    }
}

extension Request.Storage {
    func serialize() -> PB_Main {
        switch self {
        case let .info(path):
            return .with {
                $0.storageInfoRequest = .with {
                    $0.path = path.string
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
        case let .move(oldPath, newPath):
            return .with {
                $0.storageRenameRequest = .with {
                    $0.oldPath = oldPath.string
                    $0.newPath = newPath.string
                }
            }
        case let .hash(path):
            return .with {
                $0.storageMd5SumRequest = .with {
                    $0.path = path.string
                }
            }
        }
    }
}

extension Request.GUI {
    func serialize() -> PB_Main {
        switch self {
        case let .screenStream(start):
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
        case let .virtualDisplay(start):
            switch start {
            case true:
                return .with {
                    $0.guiStartVirtualDisplayRequest = .init()
                }
            case false:
                return .with {
                    $0.guiStopVirtualDisplayRequest = .init()
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

extension PBSystem_RebootRequest.RebootMode {
    init(_ source: Message.RebootMode) {
        switch source {
        case .os: self = .os
        case .dfu: self = .dfu
        case .update: self = .update
        }
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
