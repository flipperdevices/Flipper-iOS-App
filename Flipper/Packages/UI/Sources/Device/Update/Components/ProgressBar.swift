import Core
import SwiftUI

public struct UpdateProgressBar: View {
    let state: UpdateModel.State.Update.Progress

    public init(state: UpdateModel.State.Update.Progress) {
        self.state = state
    }

    var image: String {
        switch state {
        case .downloading: return "DownloadingUpdate"
        default: return "UploadingUpdate"
        }
    }

    var text: String? {
        state == .preparing
        ? "..."
        : nil
    }

    var color: Color {
        switch state {
        case .downloading: return .sGreenUpdate
        case .preparing, .uploading: return .a2
        }
    }

    var progress: Double {
        switch state {
        case .downloading(let progress): return progress
        case .uploading(let progress): return progress
        default: return 0
        }
    }

    public var body: some View {
        ProgressBarView(
            color: color,
            progress: progress,
            image: image,
            text: text)
    }
}
