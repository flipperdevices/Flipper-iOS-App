import ActivityKit
import WidgetKit
import SwiftUI
import Core
import UI

@available(iOSApplicationExtension 16.2, *)
struct LiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: UpdateActivityAttibutes.self) { context in
            LockScreenBanner(
                state: context.state,
                version: context.attributes.version
            )
            .padding(.vertical, 14)
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

    struct LockScreenBanner: View {
        let state: UpdateModel.State.Update.Progress
        let version: Update.Version

        var color: Color {
            switch state {
            case .downloading: return .sGreenUpdate
            case .preparing, .uploading: return .a2
            }
        }

        var body: some View {
            VStack(spacing: 8) {
                Version(version)
                    .font(.system(size: 18, weight: .medium))
                UpdateProgressBar(state: state)
                    .padding(.horizontal, 24)
                UpdateProgressDescription(state: state)
            }
        }
    }

    struct CompactLeading: View {
        var body: some View {
            Image("FlipperIslandCompact")
                .resizable()
                .scaledToFit()
        }
    }

    struct CompactTrailing: View {
        let state: UpdateActivityAttibutes.ContentState

        var color: Color {
            switch state {
            case .downloading: return .sGreenUpdate
            case .preparing, .uploading: return .a2
            }
        }

        var body: some View {
            switch state {
            case .preparing:
                ProgressView()
            case .downloading(let progress):
                CompactProgress(progress, color)
            case .uploading(let progress):
                CompactProgress(progress, color)
            }
        }
    }

    struct CompactProgress: View {
        let progress: Double
        let color: Color

        var lineWidth: Double { 3 }

        init(_ progress: Double, _ color: Color) {
            self.progress = progress
            self.color = color
        }

        var body: some View {
            ZStack {
                Circle()
                    .stroke(lineWidth: lineWidth)
                    .opacity(0.3)
                    .foregroundColor(color.opacity(0.9))

                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(style: .init(
                        lineWidth: lineWidth,
                        lineCap: .round,
                        lineJoin: .round))
                    .foregroundColor(color)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: progress)
            }
            .padding(lineWidth / 2)
        }
    }
}

@available(iOSApplicationExtension 16.2, *)
struct ActivityWidgetLiveActivity_Previews: PreviewProvider {
    static let attributes = UpdateActivityAttibutes(version: .init(
        name: "0.61",
        channel: .release))
    static let contentState = UpdateActivityAttibutes.ContentState.uploading(10)

    static var previews: some View {
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
            .previewDisplayName("Island Compact")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
            .previewDisplayName("Island Expanded")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
            .previewDisplayName("Minimal")
        attributes
            .previewContext(contentState, viewKind: .content)
            .previewDisplayName("Notification")
    }
}
