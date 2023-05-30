import SwiftProtobuf
import struct Foundation.Date
import struct Foundation.Data

public enum Request {
    case system(System)
    case storage(Storage)
    case application(Application)
    case desktop(Desktop)
    case gui(GUI)

    public enum System {
        case deviceInfo
        case powerInfo
        case property(String)
        case alert
        case ping([UInt8])
        case getDate
        case setDate(Date)
        case update(Path)
    }

    public enum Storage {
        case info(Path)
        case list(Path)
        case stat(Path)
        case read(Path)
        case write(Path, [UInt8])
        case create(Path, isDirectory: Bool)
        case delete(Path, isForce: Bool)
        case move(Path, Path)
        case hash(Path)
        case timestamp(Path)
    }

    public enum Application {
        case start(String, String)
        case lockStatus
        case loadFile(Path)
        case pressButton(String)
        case releaseButton
        case exit
    }

    public enum Desktop {
        case status
        case unlock
    }

    public enum GUI {
        case screenStream(Bool)
        case virtualDisplay(Bool, ScreenFrame?)
        case button(InputKey, InputType)
    }
}

extension Request {
    func serialize() -> PB_Main {
        switch self {
        case .system(let request): return request.serialize()
        case .storage(let request): return request.serialize()
        case .application(let request): return request.serialize()
        case .desktop(let request): return request.serialize()
        case .gui(let request): return request.serialize()
        }
    }
}

extension Request.System {
    func serialize() -> PB_Main {
        switch self {
        case .deviceInfo:
            return .with {
                $0.systemDeviceInfoRequest = .init()
            }
        case .powerInfo:
            return .with {
                $0.systemPowerInfoRequest = .init()
            }
        case .property(let key):
            return .with {
                $0.propertyGetRequest = .with {
                    $0.key = key
                }
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
                    $0.updateManifest = manifest.string
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
        case let .stat(path):
            return .with {
                $0.storageStatRequest = .with {
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
        case let .timestamp(path):
            return .with {
                $0.storageTimestampRequest = .with {
                    $0.path = path.string
                }
            }
        }
    }
}

extension Request.Application {
    func serialize() -> PB_Main {
        switch self {
        case let .start(name, args):
            return .with {
                $0.appStartRequest = .with {
                    $0.name = name
                    $0.args = args
                }
            }
        case .lockStatus:
            return .with {
                $0.appLockStatusRequest = .init()
            }
        case let .loadFile(path):
            return .with {
                $0.appLoadFileRequest = .with {
                    $0.path = path.string
                }
            }
        case let .pressButton(button):
            return .with {
                $0.appButtonPressRequest = .with {
                    $0.args = button
                }
            }
        case .releaseButton:
            return .with {
                $0.appButtonReleaseRequest = .init()
            }
        case .exit:
            return .with {
                $0.appExitRequest = .init()
            }
        }
    }
}

extension Request.Desktop {
    func serialize() -> PB_Main {
        switch self {
        case .status:
            return .with {
                $0.desktopIsLockedRequest = .init()
            }
        case .unlock:
            return .with {
                $0.desktopUnlockRequest = .init()
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
        case let .virtualDisplay(start, frame):
            switch start {
            case true:
                if let frame = frame {
                    return .with {
                        $0.guiStartVirtualDisplayRequest = .with {
                            $0.firstFrame = .init(frame)
                        }
                    }
                } else {
                    return .with {
                        $0.guiStartVirtualDisplayRequest = .init()
                    }
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

extension PBGui_ScreenFrame {
    init(_ source: ScreenFrame) {
        self = .with {
            $0.data = Data(source.bytes)
        }
    }
}

extension Request: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .system(system): return "system(\(system))"
        case let .storage(storage): return "storage(\(storage))"
        case let .application(application): return "application(\(application))"
        case let .desktop(desktop): return "desktop(\(desktop))"
        case let .gui(gui): return "gui(\(gui))"
        }
    }
}

extension Request.System: CustomStringConvertible {
    public var description: String {
        switch self {
        case .deviceInfo: return "deviceInfo"
        case .powerInfo: return "powerInfo"
        case .property(let key): return "property(\(key))"
        case .alert: return "alert"
        case .ping(let bytes): return "ping(\(bytes.count) bytes)"
        case .getDate: return "info"
        case .setDate(let date): return "setDate(\(date))"
        case .update(let manifest): return "update(\(manifest))"
        }
    }
}

extension Request.Storage: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .info(path):
            return "info(\(path))"
        case let .list(path):
            return "list(\(path))"
        case let .stat(path):
            return "stat(\(path))"
        case let .read(path):
            return "read(\(path))"
        case let .write(path, bytes):
            return "write(\(path), \(bytes.count) bytes)"
        case let .create(path, isDirectory):
            return "create(\(path), \(isDirectory))"
        case let .delete(path, isForce):
            return "delete(\(path), \(isForce))"
        case let .move(from, to):
            return "move(\(from), \(to))"
        case let .hash(path):
            return "hash(\(path))"
        case let .timestamp(path):
            return "timestamp(\(path))"
        }
    }
}


extension Request.Application: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .start(name, args):
            return "start(\(name), \(args))"
        case .lockStatus:
            return "lockStatus"
        case let .loadFile(path):
            return "loadFile(\(path))"
        case let .pressButton(button):
            return "pressButton(\(button))"
        case .releaseButton:
            return "releaseButton"
        case .exit:
            return "exit"
        }
    }
}

extension Request.Desktop: CustomStringConvertible {
    public var description: String {
        switch self {
        case .status:
            return "status"
        case .unlock:
            return "unlock"
        }
    }
}

extension Request.GUI: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .screenStream(start):
            return "screenStream(\(start))"
        case let .virtualDisplay(start, frame):
            if let frame = frame {
                return "virtualDisplay(\(start), \(frame.bytes.count) bytes)"
            } else {
                return "virtualDisplay(\(start))"
            }
        case let .button(key, type):
            return "button(\(key), \(type))"
        }
    }
}
