import ActivityKit

public struct UpdateActivityAttibutes: ActivityAttributes {

    public typealias ContentState = UpdateModel.State.Update.Progress

    public var version: Update.Version

    public init(version: Update.Version) {
        self.version = version
    }
}
