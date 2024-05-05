#if canImport(ActivityKit)
import ActivityKit

public struct UpdateActivityAttibutes: ActivityAttributes {
    public typealias ContentState = Update.State

    public var version: Update.Version

    public init(version: Update.Version) {
        self.version = version
    }
}
#endif
