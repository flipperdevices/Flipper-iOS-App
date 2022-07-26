import SwiftUI

struct HexEditor: View {
    @EnvironmentObject var hexKeyboardController: HexKeyboardController

    @Binding var bytes: [UInt8?]
    let width: Double
    @State private var input: String = ""
    @State private var selectedIndex: Int?

    var sectionsRange: Range<Int> {
        0..<(bytes.count + 63) / 64
    }

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 24) {
            ForEach(sectionsRange, id: \.self) { i in
                HexEditorSection(
                    sector: i,
                    width: width,
                    selectedIndex: $selectedIndex,
                    input: $input,
                    bytes: $bytes)
            }
        }
        .onChange(of: selectedIndex) { selectedIndex in
            input = ""
            guard let selectedIndex = selectedIndex else {
                hexKeyboardController.hide()
                return
            }
            hexKeyboardController.show { key in
                guard key != .ok else {
                    self.selectedIndex = nil
                    return
                }
                guard case let .hex(button) = key else {
                    return
                }
                input += button
                if input.count == 2 {
                    bytes[selectedIndex] = UInt8(input, radix: 16) ?? 0
                    if selectedIndex + 1 < bytes.count {
                        self.selectedIndex = selectedIndex + 1
                    } else {
                        self.selectedIndex = nil
                    }
                }
            }
        }
    }
}

var demoBytes: [UInt8] {
    var result = [UInt8]()
    for _ in 0..<256 {
        result += [
            0xB6, 0x69, 0x03, 0x36, 0x8A, 0x98, 0x02, 0x00,
            0x64, 0x8F, 0x76, 0x14, 0x51, 0x10, 0x37, 0x11
        ]
    }
    return result
}
