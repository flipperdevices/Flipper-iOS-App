import Core
import SwiftUI

public struct Version: View {
    let version: Update.Version

    public init(_ version: Update.Version) {
        self.version = version
    }

    public var body: some View {
        Text(version.description)
            .foregroundColor(version.color)
    }
}

extension Update.Version {
    public var color: Color {
        channel.color
    }
}

extension Update.Channel {
    public var color: Color {
        switch self {
        case .development: return .development
        case .candidate: return .candidate
        case .release: return .release
        case .file: return .custom
        case .url: return .custom
        }
    }
}
