import Core

import SwiftUI

struct SelectChannel: View {
    let version: Update.Version
    let onChannelSelected: (Update.Channel) -> Void

    @State private var showChannelSelector = false
    @State private var channelSelectorOffset: Double = .zero

    var body: some View {
        SelectChannelButton(version: version) {
            showChannelSelector = true
        }
        .background(GeometryReader {
            Color.clear.preference(
                key: SelectChannelOffsetKey.self,
                value: $0.frame(in: .global).origin.y)
        })
        .onPreferenceChange(SelectChannelOffsetKey.self) {
            channelSelectorOffset = $0
        }
        .popup(isPresented: $showChannelSelector) {
            SelectChannelPopup {
                showChannelSelector = false
                onChannelSelected($0)
            }
            .offset(y: channelSelectorOffset - 14)
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
        case .custom: return "Custom"
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

                Image(systemName: "chevron.down")
                    .foregroundColor(.black30)
            }
            .frame(height: 44)
        }
    }
}

private struct SelectChannelOffsetKey: PreferenceKey {
    typealias Value = Double

    static var defaultValue = Double.zero

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}
