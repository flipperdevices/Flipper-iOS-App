import SwiftUI

// Copied & Adapted from UI

public struct UpdateProgressVersion: View {
    let version: Update.Version

    public init(_ version: Update.Version) {
        self.version = version
    }

    public var body: some View {
        Text(version.description)
            .foregroundColor(version.color)
            .lineLimit(1)
            .padding(.horizontal, 12)
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
        case .custom: return .custom
        }
    }
}

extension Update.Version: CustomStringConvertible {
    public var description: String {
        switch channel {
        case .development: return "Dev \(name)"
        case .candidate: return "RC \(name.dropLast(3))"
        case .release: return "Release \(name)"
        case .custom: return "Custom \(name)"
        }
    }
}
