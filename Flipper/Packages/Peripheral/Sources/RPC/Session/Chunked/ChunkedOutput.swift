import struct Foundation.Data

class ChunkedOutput {
    private var queue: [UInt8] = .init()
    var isEmpty: Bool { queue.isEmpty }

    func feed(_ main: PB_Main) {
        // shouldn't throw
        // swiftlint:disable force_try
        queue.append(contentsOf: try! main.serialize())
    }

    func drain(upTo limit: Int) -> [UInt8] {
        guard !isEmpty else { return [] }
        let data = queue.prefix(min(limit, queue.count))
        queue.removeFirst(data.count)
        return .init(data)
    }
}
