import SwiftUI

struct SelectChannel: View {
    let firmware: String
    let color: Color
    let onChannelSelected: (String) -> Void

    @State private var showChannelSelector = false
    @State private var channelSelectorOffset: Double = .zero

    var body: some View {
        SelectChannelButton(firmware: firmware, color: color) {
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
        .popup(isPresented: $showChannelSelector, hideOnTap: true) {
            SelectChannelPopup(offset: channelSelectorOffset) {
                showChannelSelector = false
                onChannelSelected($0)
            }
        }
    }
}

struct SelectChannelButton: View {
    let firmware: String
    let color: Color
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 6) {
                Spacer()
                Text(firmware)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(color)
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
