import WidgetKit

struct Entry: TimelineEntry {
    let date: Date
    let state: State

    enum State: Equatable {
        case loading
        case disconnected
        case connected(Int, Bool)
    }
}
