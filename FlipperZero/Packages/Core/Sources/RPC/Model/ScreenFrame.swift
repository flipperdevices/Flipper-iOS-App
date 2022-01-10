public struct ScreenFrame {
    let bytes: [UInt8]

    var width: Int { 128 }
    var height: Int { 64 }

    public var pixels: [Bool] {
        var result: [Bool] = []

        for row in 0..<height {
            for column in 0..<width {
                let byte = bytes[(row / 8) * width + column]
                result.append((byte & (1 << (row & 0b111))) != 0)
            }
        }

        return result
    }

    public init() {
        self.bytes = .init(repeating: 0, count: 1024)
    }

    public init?(_ bytes: [UInt8]) {
        guard bytes.count == 1024 else {
            print("invalid screen frame bytes")
            return nil
        }
        self.bytes = bytes
    }
}
