import SwiftUI

struct HexEditorSection: View {
    let sector: Int
    let width: Double

    @Binding var selectedIndex: Int?
    @Binding var input: String
    @Binding var bytes: [UInt8?]

    let columnsCount = 16
    let rowsCount = 4

    var bytesCount: Int {
        columnsCount * rowsCount
    }

    var offset: Int {
        sector * bytesCount
    }

    var rowOffset: Int {
        sector * 4
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
                id: offset / 16 + i,
                bytes: .init(bytes[offset...].prefix(16))))
            if bytes.count >= columnsCount {
                bytes.removeFirst(columnsCount)
            }
        }
        return rows
    }

    var hasKeys: Bool {
        rows.contains {
            $0.columns.contains {
                $0.byte != nil
            }
        }
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
        selectedIndex = row * columnsCount + column
    }

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            Text("Sector: \(sector)")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .padding(.leading, lineNumberWidth + bytePadding)
                .padding(.bottom, 6)

            if !hasKeys {
                HStack(spacing: 0) {
                    Text("No Keys Found")
                        .padding(.leading, lineNumberWidth + bytePadding)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black40)
                }
            } else {
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
                                    .background(Color(uiColor: .lightGray))
                            } else {
                                HexByte(byte: column.byte)
                                    .padding(bytePadding)
                                    .frame(width: byteWidth, height: byteHeight)
                                    .onTapGesture {
                                        makeSelected(row.id, column.id)
                                    }
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
