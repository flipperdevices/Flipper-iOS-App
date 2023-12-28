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

    struct LockScreenBanner: View {
        let state: UpdateModel.State.Update
        let version: Update.Version

        var body: some View {
            switch state {
            case .progress(let progress):
                Progress(state: progress, version: version)
            case .result(let result):
                Result(state: result, version: version)
            }
        }

        struct Progress: View {
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

        struct Result: View {
            let state: UpdateModel.State.Update.Result
            let version: Update.Version

            var body: some View {
                switch state {
                case .started: Started()
                case .canceled: Canceled()
                case .succeeded: Succeeded()
                case .failed: Failed()
                }
            }

            struct Started: View {
                var body: some View {
                    VStack(spacing: 8) {
                        Image("UpdateStartedActivity")
                        Text(
                            "Flipper is updating in offline mode. " +
                            "Check the device \nscreen for info and " +
                            "wait for reconnect."
                        )
                        .font(.system(size: 12, weight: .medium))
                        .lineLimit(2, reservesSpace: true)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black30)
                    }
                }
            }

            struct Canceled: View {
                var body: some View {
                    VStack(spacing: 8) {
                        Image("UpdateCanceledActivity")
                        Text("Update Aborted")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.sRed)
                    }
                }
            }

            struct Succeeded: View {
                var body: some View {
                    VStack(spacing: 8) {
                        Image("UpdateSuccessActivity")
                        Text("Update Successful")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.sGreenUpdate)
                    }
                }
            }

            struct Failed: View {
                var body: some View {
                    VStack(spacing: 8) {
                        Image("UpdateFailedActivity")
                        Text("Update Failed")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.sRed)
                    }
                }
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

        var body: some View {
            switch state {
            case .progress(let progress):
                Progress(state: progress)
            case .result(let result):
                Result(state: result)
            }
        }

        struct Progress: View {
            let state: UpdateActivityAttibutes.ContentState.Progress

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

        struct Result: View {
            let state: UpdateActivityAttibutes.ContentState.Result

            var body: some View {
                EmptyView()
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
