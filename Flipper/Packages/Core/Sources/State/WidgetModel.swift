public struct WidgetModel {
    public var keys: [WidgetKey] = []
    public var keyToEmulate: WidgetKey?

    public var isExpanded = false

    public var showSettings = false

    public var state: State = .idle

    public var isEmulating: Bool {
        state == .emulating
    }

    public var isError: Bool {
        switch state {
        case .error: return true
        default: return false
        }
    }

    public enum State: Equatable {
        case idle
        case loading
        case emulating
        case error(Error)

        public enum Error: Equatable {
            case appLocked
            case notSynced
            case cantConnect
            case bluetoothOff
        }
    }
}
