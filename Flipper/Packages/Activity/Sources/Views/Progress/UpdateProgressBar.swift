import SwiftUI

// Copied & Adapted from UI

public struct UpdateProgressBar: View {
    let state: Update.State.Progress

    public init(state: Update.State.Progress) {
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
        ProgressBar(
            color: color,
            progress: progress,
            image: image,
            text: text)
    }
}
