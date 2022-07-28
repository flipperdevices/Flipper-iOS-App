public enum Message {
    case error(Error)
    case screenFrame(ScreenFrame)
    case appState(AppState)
    case reboot(RebootMode)
    case unknown(String)

    public enum RebootMode {
        case os
        case dfu
        case update
    }

    public enum AppState {
        case closed
        case started
        case unknown
    }
}

extension Message {
    init(decoding main: PB_Main) {
        guard main.commandStatus == .ok else {
            self = .error(.init(main.commandStatus))
            return
        }
        switch main.content {
        case .guiScreenFrame(let response):
            self.init(decoding: response)
        case .appStateResponse(let response):
            self.init(decoding: response)
        default:
            self = .unknown("\(main)")
        }
    }

    init(decoding response: PBGui_ScreenFrame) {
        guard let frame = ScreenFrame(.init(response.data)) else {
            self = .screenFrame(.init())
            return
        }
        self = .screenFrame(frame)
    }

    init(decoding response: PBApp_AppStateResponse) {
        switch response.state {
        case .appClosed: self = .appState(.closed)
        case .appStarted: self = .appState(.started)
        default: self = .appState(.unknown)
        }
    }
}

extension Message {
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
        default:
            fatalError("unreachable")
        }
    }
}
