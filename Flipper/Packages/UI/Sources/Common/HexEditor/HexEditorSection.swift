import SwiftUI

struct HexEditorSection: View {
    let sector: Sector
    let width: Double

    @Binding var selectedIndex: Int?
    @Binding var input: String
    @Binding var bytes: [UInt8?]

    var offset: Int { sector.offset }
    var lineOffset: Int { sector.lineOffset }
    var columnsCount: Int { sector.columnsCount }
    var rowsCount: Int { sector.rowsCount }

    struct Sector {
        let number: Int
        let offset: Int
        let lineOffset: Int
        let columnsCount: Int
        let rowsCount: Int
    }

    struct Row: Identifiable {
        let id: Int
        let columns: [Column]

        init(id: Int, bytes: [UInt8?]) {
            self.id = id
            var columns = [Column]()
            for (index, byte) in bytes.enumerated() {
                columns.append(.init(id: index, byte: byte))
            }
            self.columns = columns
        }
    }

    struct Column: Identifiable {
        let id: Int
        let byte: UInt8?
    }

    var rows: [Row] {
        var bytes = bytes
        var rows = [Row]()
        for i in 0 ..< rowsCount {
            rows.append(.init(
                id: lineOffset + i,
                bytes: .init(bytes[offset...].prefix(columnsCount))))
            if bytes.count >= columnsCount {
                bytes.removeFirst(columnsCount)
            }
        }
        return rows
    }

    var symbolWidth: Double {
        let symbolsCount = 3 + columnsCount * 2
        return width / Double(symbolsCount)
    }
    var byteWidth: Double { symbolWidth * 2 }
    var byteHeight: Double { byteWidth }
    var bytePadding: Double { symbolWidth / 6 }
    var lineNumberWidth: Double { symbolWidth * 4 }

    func isSelected(_ row: Int, _ column: Int) -> Bool {
        row * columnsCount + column == selectedIndex
    }

    func makeSelected(_ row: Int, _ column: Int) {
        guard row != 0 else { return }
        selectedIndex = row * columnsCount + column
    }

    func color(_ row: Int, _ column: Int) -> Color {
        let row = row % rowsCount
        guard row != 0 else {
            return sector.number == 0 ? .candidate : .primary
        }
        guard row == rowsCount - 1 else {
            return .primary
        }
        switch column {
        case 0...5: return .sGreenUpdate
        case 6...8: return .sRed
        case 10...15: return .a2
        default: return .primary
        }
    }

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            Text("Sector: \(sector.number)")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .padding(.leading, lineNumberWidth + bytePadding)
                .padding(.bottom, 6)

            ForEach(rows) { row in
                HStack(spacing: 0) {
                    LineNumber(row.id)
                        .padding(bytePadding)
                        .frame(width: lineNumberWidth, height: byteHeight)
                        .foregroundColor(.black16)

                    ForEach(row.columns) { column in
                        if isSelected(row.id, column.id) {
                            HexByteEditor(byte: column.byte, input: $input)
                                .padding(bytePadding)
                                .frame(width: byteWidth, height: byteHeight)
                                .foregroundColor(color(row.id, column.id))
                                .background(Color(uiColor: .lightGray))
                        } else {
                            HexByte(byte: column.byte)
                                .padding(bytePadding)
                                .frame(width: byteWidth, height: byteHeight)
                                .foregroundColor(color(row.id, column.id))
                                .onTapGesture {
                                    makeSelected(row.id, column.id)
                                }
                        }
                    }
                }
            }
        }
        .font(.system(size: 60, weight: .medium, design: .monospaced))
        .minimumScaleFactor(0.1)
    }
}

struct LineNumber: View {
    let number: Int

    init(_ number: Int) {
        self.number = number
    }

    var body: some View {
        HStack {
            Spacer()
            Text("\(number)")
        }
    }
}

struct HexByte: View {
    let byte: UInt8?

    var string: String {
        guard let byte = byte else {
            return "??"
        }
        if byte < 16 {
            return "0" + String(byte, radix: 16).uppercased()
        } else {
            return String(byte, radix: 16).uppercased()
        }
    }

    var body: some View {
        Text(string)
    }
}

struct HexByteEditor: View {
    let byte: UInt8?

    @Binding var input: String

    var string: String {
        if input.isEmpty {
            guard let byte = byte else {
                return "??"
            }
            if byte < 16 {
                return "0" + String(byte, radix: 16).uppercased()
            } else {
                return String(byte, radix: 16).uppercased()
            }
        } else {
            return input + " "
        }
    }

    var body: some View {
        Text(string)
    }
}
