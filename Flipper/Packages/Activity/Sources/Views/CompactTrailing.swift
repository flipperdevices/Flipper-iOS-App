import SwiftUI

public struct CompactTrailing: View {
    let state: Update.State

    public init(state: Update.State) {
        self.state = state
    }

    public var body: some View {
        switch state {
        case .progress(let progress):
            Progress(state: progress)
        case .result(let result):
            Result(state: result)
        }
    }

    struct Progress: View {
        let state: Update.State.Progress

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

        public var body: some View {
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

    struct Result: View {
        let state: Update.State.Result

        var body: some View {
            EmptyView()
        }
    }
}
