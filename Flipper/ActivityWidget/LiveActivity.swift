import ActivityKit
import WidgetKit
import SwiftUI
import Activity

@available(iOSApplicationExtension 16.2, *)
struct LiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: UpdateActivityAttibutes.self) { context in
            LockScreenBanner(
                state: context.state,
                version: context.attributes.version
            )
            .padding(14)
            .activityBackgroundTint(.black)
            .activitySystemActionForegroundColor(Color.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    LockScreenBanner(
                        state: context.state,
                        version: context.attributes.version
                    )
                }
            } compactLeading: {
                CompactLeading()
            } compactTrailing: {
                CompactTrailing(state: context.state)
            } minimal: {
                CompactTrailing(state: context.state)
            }
        }
    }
}

@available(iOSApplicationExtension 16.2, *)
struct ActivityWidgetLiveActivity_Previews: PreviewProvider {
    static let attributes = UpdateActivityAttibutes(version: .init(
        name: "0.61",
        channel: .release))
    static let contentState = UpdateActivityAttibutes.ContentState
        .progress(.uploading(0.5))

    static var previews: some View {
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
            .previewDisplayName("Progress Compact")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
            .previewDisplayName("Progress Expanded")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
            .previewDisplayName("Progress Minimal")
        attributes
            .previewContext(contentState, viewKind: .content)
            .previewDisplayName("Progress Notification")
    }
}

@available(iOSApplicationExtension 16.2, *)
struct ActivityWidgetLiveActivity2_Previews: PreviewProvider {
    static let attributes = UpdateActivityAttibutes(version: .init(
        name: "0.61",
        channel: .release))
    static let contentState = UpdateActivityAttibutes.ContentState
        .result(.started)

    static var previews: some View {
        attributes
            .previewContext(.result(.started), viewKind: .content)
            .previewDisplayName("Started Notification")
        attributes
            .previewContext(.result(.canceled), viewKind: .content)
            .previewDisplayName("Canceled Notification")
        attributes
            .previewContext(.result(.failed), viewKind: .content)
            .previewDisplayName("Failed Notification")
    }
}
