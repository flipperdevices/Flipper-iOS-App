import Core

import SwiftUI

struct SelectChannelPopup: View {
    let onChannelSelected: (Update.Channel) -> Void

    var body: some View {
        HStack {
            Spacer()
            Card {
                VStack(alignment: .leading, spacing: 0) {
                    ChannelMenuRow(
                        title: "Release",
                        color: Update.Channel.release.color,
                        description: "Stable release (recommended)",
                        onClick: { onChannelSelected(.release) }
                    )
                    .padding(12)

                    Divider()
                        .padding(0)

                    ChannelMenuRow(
                        title: "Release-Candidate",
                        color: Update.Channel.candidate.color,
                        description: "Pre-release under testing",
                        onClick: { onChannelSelected(.candidate) }
                    )
                    .padding(12)

                    Divider()
                        .padding(0)

                    ChannelMenuRow(
                        title: "Development",
                        color: Update.Channel.development.color,
                        description: "Daily unstable build, lots of bugs",
                        onClick: { onChannelSelected(.development) }
                    )
                    .padding(12)
                }
            }
            .frame(width: 220)
        }
    }
}

struct ChannelMenuRow: View {
    let title: String
    let color: Color
    let description: String
    var onClick: () -> Void

    var body: some View {
        Button {
            onClick()
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
