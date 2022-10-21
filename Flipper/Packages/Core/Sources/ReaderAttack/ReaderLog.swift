import MFKey32v2

public struct ReaderLog {
    public let lines: [Line]

    public struct Line: Sendable {
        public let number: Int
        public let sector: Int
        public let keyType: KeyType
        public let readerData: ReaderData
    }

    public enum KeyType: String, Sendable {
        case a = "A"
        case b = "B"
    }

    public struct Error: Swift.Error {
        let line: Int
        let source: Source

        enum Source {
            case line, sector, keyType, uid, nt0, nr0, ar0, nt1, nr1, ar1
        }
    }

    public init(_ log: String) throws {
        var result: [Line] = []

        let lines = log.split { $0 == "\n" || $0 == "\r\n" }

        for (index, line) in lines.enumerated() {
            let number = index + 1
            let columns = line.split(separator: " ").map(String.init)
            guard columns.count == 18 else {
                throw Error(line: number + 1, source: .line)
            }

            let sectorString = columns[1]
            let keyTypeString = columns[3]
            let uidString = columns[5]
            let nt0String = columns[7]
            let nr0String = columns[9]
            let ar0String = columns[11]
            let nt1String = columns[13]
            let nr1String = columns[15]
            let ar1String = columns[17]

            guard let sector = Int(sectorString) else {
                throw Error(line: number, source: .sector)
            }
            guard let keyType = KeyType(rawValue: keyTypeString) else {
                throw Error(line: number, source: .keyType)
            }
            guard let uid = UInt32(uidString, radix: 16) else {
                throw Error(line: number, source: .uid)
            }
            guard let nt0 = UInt32(nt0String, radix: 16) else {
                throw Error(line: number, source: .nt0)
            }
            guard let nr0 = UInt32(nr0String, radix: 16) else {
                throw Error(line: number, source: .nr0)
            }
            guard let ar0 = UInt32(ar0String, radix: 16) else {
                throw Error(line: number, source: .ar0)
            }
            guard let nt1 = UInt32(nt1String, radix: 16) else {
                throw Error(line: number, source: .nt1)
            }
            guard let nr1 = UInt32(nr1String, radix: 16) else {
                throw Error(line: number, source: .nr1)
            }
            guard let ar1 = UInt32(ar1String, radix: 16) else {
                throw Error(line: number, source: .ar1)
            }

            result.append(.init(
                number: number,
                sector: sector,
                keyType: keyType,
                readerData: .init(
                    uid: uid,
                    nt0: nt0,
                    nr0: nr0,
                    ar0: ar0,
                    nt1: nt1,
                    nr1: nr1,
                    ar1: ar1)))
        }

        self.lines = result
    }
}
