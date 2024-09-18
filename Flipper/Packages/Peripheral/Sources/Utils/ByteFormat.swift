import Foundation

extension Int {
    private var bytes: Int {
        1024
    }

    private var units: [String] {
        ["KiB", "MiB", "GiB", "TiB", "PiB", "EiB", "ZiB", "YiB"]
    }

    public var hr: String {
        guard self >= bytes else { return "\(self) B" }
        let exp = Int(log2(Double(self)) / log2(Double(bytes)))
        let unit = units[exp - 1]
        let number = Double(self) / pow(Double(bytes), Double(exp))
        return (exp <= 1 || number >= 100)
            ? String(format: "%.0f %@", number, unit)
            : String(format: "%.1f %@", number, unit)
                .replacingOccurrences(of: ".0", with: "")
    }
}
