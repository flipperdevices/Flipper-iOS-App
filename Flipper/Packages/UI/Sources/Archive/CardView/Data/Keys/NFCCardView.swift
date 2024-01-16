import Core
import SwiftUI

struct NFCCardView: View {
    @Binding var item: ArchiveItem

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            PropertyView(name: "Device Type:", value: item.type)
            PropertyView(name: "UID:", value: item.uid)
        }
    }
}

private extension ArchiveItem {
    var props: [Property] {
        shadowCopy.isEmpty
            ? self.properties
            : self.shadowCopy
    }

    var type: String { props["Device type"] ?? "" }
    var uid: String { props["UID"] ?? "" }
}
