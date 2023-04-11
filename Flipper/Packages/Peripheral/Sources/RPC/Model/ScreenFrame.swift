
public struct ScreenFrame: Equatable {
    let bytes: [UInt8]
    public let orientation: Orientation

    public enum Orientation: Int {
        case horizontal
        case horizontalFlipped
        case vertical
        case verticalFlipped

        public var isHorizontal: Bool {
            self == .horizontal || self == .horizontalFlipped
        }
    }

    static var width: Int { 128 }
    static var height: Int { 64 }
    static var pixelCount: Int { width * height }

    public var pixels: [Bool] {
        var result: [Bool] = []

        for row in 0..<Self.height {
            for column in 0..<Self.width {
                let byte = bytes[(row / 8) * Self.width + column]
                result.append((byte & (1 << (row & 0b111))) != 0)
            }
        }

        return result
    }

    public init() {
        self.bytes = .init(repeating: 0, count: Self.pixelCount / 8)
        self.orientation = .horizontal
    }

    public init?(bytes: [UInt8], orientation: Orientation) {
        guard bytes.count < Self.pixelCount else {
            logger.error("invalid screen frame bytes")
            return nil
        }
        self.bytes = bytes
        self.orientation = orientation
    }

    public init?(pixels: [Bool], orientation: Orientation) {
        if pixels.count != Self.width * Self.height {
            logger.error("invalid pixel count")
            return nil
        }
        var bytes = [UInt8](repeating: 0, count: Self.pixelCount / 8)
        for (index, pixel) in pixels.enumerated() where pixel {
            bytes[index / 8] = bytes[index / 8] | (1 << (index % 8))
        }
        self.bytes = bytes
        self.orientation = orientation
    }
}
