import SwiftUI

struct SelectChannelPopup: View {
    let offset: Double
    let onChannelSelected: (String) -> Void

    var body: some View {
        HStack {
            Spacer()
            Card {
                VStack(alignment: .leading, spacing: 0) {
                    ChannelMenuRow(
                        title: "Release",
                        description: "Stable release (recommended)",
                        onClick: onChannelSelected
                    )
                    .padding(12)

                    Divider()
                        .padding(0)

                    ChannelMenuRow(
                        title: "Release-Candidate",
                        description: "Pre-release under testing",
                        onClick: onChannelSelected
                    )
                    .padding(12)

                    Divider()
                        .padding(0)

                    ChannelMenuRow(
                        title: "Development",
                        description: "Daily unstable build, lots of bugs",
                        onClick: onChannelSelected
                    )
                    .padding(12)
                }
            }
            .frame(width: 220)
        }
        .offset(y: offset - 14)
        .padding(.trailing, 14)
    }
}

struct ChannelMenuRow: View {
    let title: String
    let description: String
    var onClick: (String) -> Void

    var color: Color {
        switch title {
        case "Release": return .release
        case "Release-Candidate": return .candidate
        case "Development": return .development
        default: return .clear
        }
    }

    var body: some View {
        Button {
            onClick(title)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(color)
                    Text(description)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.black40)
                }
                Spacer()
            }
        }
    }
}
