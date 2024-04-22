public enum OutgoingMessage {
    case screenFrame(ScreenFrame)
    case reboot(RebootMode)

    public enum RebootMode {
        case os
        case dfu
        case update
    }
}

extension PBSystem_RebootRequest.RebootMode {
    init(_ source: OutgoingMessage.RebootMode) {
        switch source {
        case .os: self = .os
        case .dfu: self = .dfu
        case .update: self = .update
        }
    }
}

extension OutgoingMessage {
    func serialize() -> PB_Main {
        switch self {
        case .screenFrame(let screenFrame):
            return .with {
                $0.guiScreenFrame = .with {
                    $0.data = .init(screenFrame.bytes)
                }
            }
        case .reboot(let mode):
            return .with {
                $0.systemRebootRequest = .with {
                    $0.mode = .init(mode)
                }
            }
        }
    }
}
