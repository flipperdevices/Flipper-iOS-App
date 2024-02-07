import Core

import SwiftUI

struct SelectChannel: View {
    let version: Update.Version
    let onChannelSelected: (Update.Channel) -> Void

    @State private var showChannelSelector = false
    @State private var channelSelectorOffset = 0.0

    var body: some View {
        SelectChannelButton(version: version) {
            showChannelSelector = true
        }
        .background(GeometryReader {
            Color.clear.preference(
                key: OffsetKey.self,
                value: $0.frame(in: .global).origin.y)
        })
        .onPreferenceChange(OffsetKey.self) {
            channelSelectorOffset = $0
        }
        .popup(isPresented: $showChannelSelector) {
            SelectChannelPopup {
                showChannelSelector = false
                onChannelSelected($0)
            }
            .offset(y: channelSelectorOffset + platformOffset)
            .padding(.trailing, 14)
        }
    }
}

struct SelectChannelButton: View {
    let version: Update.Version
    var action: () -> Void

    public var text: String {
        switch version.channel {
        case .development: return "Dev \(version.name)"
        case .candidate: return "RC \(version.name.dropLast(3))"
        case .release: return "Release \(version.name)"
        case .file: return "Custom"
        case .url: return version.name
        }
    }

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 6) {
                Spacer()

                Text(text)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(version.color)
                    .lineLimit(1)

                Image(systemName: "chevron.down")
                    .foregroundColor(.black30)
            }
            .frame(height: 44)
        }
    }
}
