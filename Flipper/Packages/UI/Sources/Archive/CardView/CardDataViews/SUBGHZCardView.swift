import Core
import SwiftUI

struct SUBGHZCardView: View {
    @Binding var item: ArchiveItem
    @Binding var isEditMode: Bool
    @Binding var focusedField: String

    let flipped: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !flipped {
                HStack(spacing: 4) {
                    Text("KEY:")
                    Text(item.isRaw ? "raw data" : item.key)
                        .lineLimit(1)
                }
                .font(.system(size: 18, weight: .bold))

                HStack(spacing: 4) {
                    Text("Frequency:")
                    Text(item.frequency)
                }

                if !item.isRaw {
                    Text("\(item.proto) \(item.bit) bit")
                }
            } else {
                Text(item.rawData)
                    .lineLimit(3)
            }
        }
        .font(.system(size: 16, weight: .medium))
        .padding(.top, 16)
        .padding(.bottom, 4)
        .padding(.horizontal, 16)
    }
}

fileprivate extension ArchiveItem {
    var isRaw: Bool {
        self["Filetype"] == "Flipper SubGhz RAW File"
    }

    var key: String { self["Key"] ?? "" }
    var bit: String { self["Bit"] ?? "" }
    var frequency: String { self["Frequency"] ?? "" }
    var proto: String { self["Protocol"] ?? "" }
    var rawData: String { self["RAW_Data"] ?? "" }
}
