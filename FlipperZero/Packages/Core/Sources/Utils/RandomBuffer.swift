extension Array where Element == UInt8 {
    public static func random(size: Int) -> [UInt8] {
        var bytes: [UInt8] = .init()
        bytes.reserveCapacity(size)
        for _ in 0..<size {
            bytes.append(.random())
        }
        return bytes
    }
}

extension UInt8 {
    static func random() -> UInt8 {
        .random(in: (0 ..< UInt8.max))
    }
}
