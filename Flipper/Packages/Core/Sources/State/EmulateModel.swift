public struct EmulateModel {
    public var state: State = .closed

    public enum State: Equatable {
        case staring
        case started
        case loading
        case loaded
        case emulating
        case closing
        case closed
        case locked
        case restricted
    }
}
