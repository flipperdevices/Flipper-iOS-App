import struct Foundation.Data

class PeripheralOutput {
    private var queue: Data = .init()
    private var freeSpace = 0

    weak var delegate: PeripheralOutputDelegate?

    func append(contentsOf chunks: [[UInt8]]) {
        chunks.forEach { queue.append(contentsOf: $0) }
        processDataQueue()
    }

    func didReceiveBufferSpace(_ freeSpace: Int) {
        self.freeSpace = freeSpace
        processDataQueue()
    }

    private func processDataQueue() {
        while freeSpace > 0 && !queue.isEmpty {
            let size = min(freeSpace, Limits.maxBlePacket)
            let data = queue.prefix(size)
            queue.removeFirst(data.count)
            freeSpace -= data.count
            delegate?.send(data)
        }
    }
}
