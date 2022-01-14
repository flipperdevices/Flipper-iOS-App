import struct Foundation.Data

class ChunkedOutput {
    private var queue: Data = .init()

    var hasData: Bool {
        !queue.isEmpty
    }

    func feed(_ requests: [PB_Main]) {
        for request in requests {
            // shouldn't throw
            // swiftlint:disable force_try
            queue.append(contentsOf: try! request.serialize())
        }
    }

    func next(maxSize size: Int) -> [UInt8] {
        guard hasData else { return [] }
        let data = queue.prefix(size)
        queue.removeFirst(data.count)
        return .init(data)
    }
}
