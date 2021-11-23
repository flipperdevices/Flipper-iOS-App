import struct Foundation.Data

class ChunkedRequest {
    private var queue: Data = .init()
    private var packetSize: Int = 38
    private var freeSpace = 0

    weak var delegate: PeripheralOutputDelegate?

    func feed(_ requests: [PB_Main]) {
        for request in requests {
            // shouldn't throw
            // swiftlint:disable force_try
            queue.append(contentsOf: try! request.serialize())
        }
        processDataQueue()
    }

    func didReceiveFlowControl(freeSpace: Int, packetSize: Int) {
        self.freeSpace = freeSpace
        self.packetSize = packetSize
        processDataQueue()
    }

    private func processDataQueue() {
        while freeSpace > 0 && !queue.isEmpty {
            let size = min(freeSpace, packetSize)
            let data = queue.prefix(size)
            queue.removeFirst(data.count)
            freeSpace -= data.count
            delegate?.send(data)
        }
    }
}
