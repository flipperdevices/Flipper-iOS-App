import Core
import SwiftUI

public struct UpdateProgressDescription: View {
    let state: UpdateModel.State.Update.Progress

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

    public init(state: UpdateModel.State.Update.Progress) {
        self.state = state
    }

    public var body: some View {
        Text(description)
            .font(.system(size: 14, weight: .medium))
            .multilineTextAlignment(.center)
            .foregroundColor(.black30)
    }
}
