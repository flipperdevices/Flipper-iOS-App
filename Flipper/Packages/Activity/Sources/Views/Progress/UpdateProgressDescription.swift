import SwiftUI

// Copied & Adapted from UI

public struct UpdateProgressDescription: View {
    let state: Update.State.Progress

    var description: String {
        switch state {
        case .downloading:
            return "Downloading from update server..."
        case .preparing:
            return "Preparing for update..."
        case .uploading:
            return "Uploading firmware to Flipper..."
        }
    }

    public init(state: Update.State.Progress) {
        self.state = state
    }

    public var body: some View {
        Text(description)
            .font(.system(size: 14, weight: .medium))
            .multilineTextAlignment(.center)
            .foregroundColor(.black30)
    }
}
