import Core

import SwiftUI

struct Version: View {
    let version: Update.Version

    init(_ version: Update.Version) {
        self.version = version
    }

    var body: some View {
        Text(version.description)
            .foregroundColor(version.color)
    }
}

extension Update.Version {
    var color: Color {
        channel.color
    }
}

extension Update.Channel {
    var color: Color {
        switch self {
        case .development: return .development
        case .candidate: return .candidate
        case .release: return .release
        }
    }
}
