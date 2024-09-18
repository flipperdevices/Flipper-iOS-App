import Activity

public extension Activity.Update.State.Progress {
    init(_ source: UpdateModel.State.Update.Progress) {
        self =
            switch source {
            case .preparing: .preparing
            case .downloading(let value): .downloading(value)
            case .uploading(let value): .uploading(value)
            }
    }
}

public extension Activity.Update.State.Result {
    init(_ source: UpdateModel.State.Update.Result) {
        self =
            switch source {
            case .started: .started
            case .canceled: .canceled
            case .succeeded: .succeeded
            case .failed: .failed
            }
    }
}

#if canImport(ActivityKit)
public extension UpdateActivityAttibutes {
    init(_ other: Core.Update.Version) {
        self.init(version: Activity.Update.Version(other))
    }
}
#endif

public extension Activity.Update.Version {
    init(_ other: Core.Update.Version) {
        self.init(name: other.name, channel: .init(other.channel))
    }
}

public extension Activity.Update.Channel {
    init(_ other: Core.Update.Channel) {
        switch other {
        case .development: self = .development
        case .candidate: self = .candidate
        case .release: self = .release
        case .custom: self = .custom
        }
    }
}
