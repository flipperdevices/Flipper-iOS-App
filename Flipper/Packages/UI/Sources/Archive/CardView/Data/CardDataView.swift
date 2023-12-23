import Core
import SwiftUI

struct CardDataView: View {
    @Binding var item: ArchiveItem

    var body: some View {
        switch item.kind {
        case .rfid:
            CardDataInternalView {
                RFIDCardView(item: _item)
            }
        case .subghz:
            CardDataInternalView {
                SUBGHZCardView(item: _item)
            }
        case .nfc:
            CardDataInternalView {
                NFCCardView(item: _item)
            }
        case .ibutton:
            CardDataInternalView {
                IButtonCardView(item: _item)
            }
        case .infrared:
            EmptyView()
        }
    }

    struct CardDataInternalView<Content: View>: View {
        @ViewBuilder var content: () -> Content

        var body: some View {
            Divider()
                .frame(height: 1)
                .background(Color.black12)
            content()
                .padding(.horizontal, 12)
        }
    }
}
