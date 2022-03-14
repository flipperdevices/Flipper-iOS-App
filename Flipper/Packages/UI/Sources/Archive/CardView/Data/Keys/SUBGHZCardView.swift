import Core
import SwiftUI

struct SUBGHZCardView: View {
    @Binding var item: ArchiveItem
    let isEditing: Bool
    @Binding var focusedField: String

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            PropertyView(
                name: "Key:",
                value: item.isRaw ? "raw data" : item.key)

            PropertyView(
                name: "Frequency:",
                value: item.frequency)

            if item.isRaw {
                PropertyView(
                    name: "Data:",
                    value: item.rawData)
            } else {
                PropertyView(
                    name: "Info:",
                    value: "\(item.proto) \(item.bit) bit")
            }
        }
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
