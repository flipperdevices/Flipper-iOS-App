import struct Foundation.Data

class ChunkedRequest {
    private var queue: Data = .init()
    private var packetSize: Int = 38
    private var freeSpace = 0

    var canWrite: Bool {
        freeSpace > 0 && !queue.isEmpty
    }

    func feed(_ requests: [PB_Main]) {
        for request in requests {
            // shouldn't throw
            // swiftlint:disable force_try
            queue.append(contentsOf: try! request.serialize())
        }
    }

    func didReceiveFlowControl(freeSpace: Int, packetSize: Int) {
        self.freeSpace = freeSpace
        self.packetSize = packetSize
    }

    func next() -> [UInt8] {
        guard canWrite else { return [] }
        let size = min(freeSpace, packetSize)
        let data = queue.prefix(size)
        queue.removeFirst(data.count)
        freeSpace -= data.count
        return .init(data)
    }
}
