import SwiftUI

struct HexEditor: View {
    @EnvironmentObject var hexKeyboardController: HexKeyboardController

    @Binding var bytes: [UInt8?]
    let width: Double
    @State private var input: String = ""
    @State private var selectedIndex: Int?

    var sectorsRange: Range<Int> {
        bytes.count == 4096
            ? 0..<40
            : 0..<16
    }

    func sector(for sectorNumber: Int) -> HexEditorSection.Sector {
        switch sectorNumber {
        case 0..<32:
            return .init(
                number: sectorNumber,
                offset: sectorNumber * 64,
                lineOffset: sectorNumber * 4,
                columnsCount: 16,
                rowsCount: 4)
        case 32...:
            return .init(
                number: sectorNumber,
                offset: (32 * 64) + (sectorNumber - 32) * 256,
                lineOffset: (32 * 4) + (sectorNumber - 32) * 16,
                columnsCount: 16,
                rowsCount: 16)
        default:
            fatalError("unreachable")
        }
    }

    var body: some View {
        ScrollViewReader { scrollView in
            LazyVStack(alignment: .leading, spacing: 24) {
                ForEach(sectorsRange, id: \.self) { i in
                    HexEditorSection(
                        sector: sector(for: i),
                        width: width,
                        selectedIndex: $selectedIndex,
                        input: $input,
                        bytes: $bytes
                    )
                    .id(i)
                }
            }
            .onChange(of: selectedIndex) { selectedIndex in
                input = ""
                guard let selectedIndex = selectedIndex else {
                    hexKeyboardController.hide()
                    return
                }
                hexKeyboardController.show { key in
                    onKey(key)
                }
                withAnimation {
                    scrollView.scrollTo(selectedIndex / 64, anchor: .center)
                }
            }
        }
    }

    func onKey(_ key: HexKeyboardController.Key) {
        guard let selectedIndex = selectedIndex else {
            return
        }
        switch key {
        case .ok:
            self.selectedIndex = nil
        case .back:
            bytes[selectedIndex] = nil
            if selectedIndex > 16 {
                self.selectedIndex = selectedIndex - 1
            }
        case let .hex(button):
            input += button
            if input.count == 2 {
                bytes[selectedIndex] = UInt8(input, radix: 16)
                if selectedIndex + 1 < bytes.count {
                    self.selectedIndex = selectedIndex + 1
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
