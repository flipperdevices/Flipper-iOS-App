public enum Message {
    case decodeError
    case screenFrame(ScreenFrame)
}

extension Message {
    init(decoding main: PB_Main) {
        guard main.commandStatus != .errorDecode else {
            self = .decodeError
            return
        }
        switch main.content {
        case .guiScreenFrame(let response):
            self.init(decoding: response)
        default:
            fatalError("unhandled response")
        }
    }

    init(decoding response: PBGui_ScreenFrame) {
        guard let frame = ScreenFrame(.init(response.data)) else {
            self = .screenFrame(.init())
            return
        }
        self = .screenFrame(frame)
    }
}

extension Message {
    func serialize() -> PB_Main {
        switch self {
        case .decodeError:
            return .with {
                $0.commandStatus = .errorDecode
            }
        case .screenFrame(let screenFrame):
            return .with {
                $0.guiScreenFrame = .with {
                    $0.data = .init(screenFrame.bytes)
                }
            }
        }
    }
}
