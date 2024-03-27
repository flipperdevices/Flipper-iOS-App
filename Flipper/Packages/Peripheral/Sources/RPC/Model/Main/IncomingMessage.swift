public enum IncomingMessage {
    case error(Error)
    case screenFrame(ScreenFrame)
    case appState(AppState)
    case unknown(String)

    public enum AppState {
        case closed
        case started
        case unknown
    }
}

extension IncomingMessage {
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
        guard let frame = ScreenFrame(
            bytes: .init(response.data),
            orientation: .init(response.orientation)
        ) else {
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

extension ScreenFrame.Orientation {
    init(_ source: PBGui_ScreenOrientation) {
        switch source {
        case .horizontal: self = .horizontal
        case .horizontalFlip: self = .horizontalFlipped
        case .vertical: self = .vertical
        case .verticalFlip: self = .verticalFlipped
        case .UNRECOGNIZED: self = .horizontal
        }
    }
}
