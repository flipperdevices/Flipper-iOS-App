import Foundation

class InputByteStream: InputStream {
    var bytes: [UInt8]

    override var hasBytesAvailable: Bool {
        !bytes.isEmpty
    }

    init(_ bytes: [UInt8]) {
        self.bytes = bytes
        super.init(data: .init())
    }

    override func read(
        _ buffer: UnsafeMutablePointer<UInt8>,
        maxLength len: Int
    ) -> Int {
        let count = min(len, bytes.count)
        let buffer = UnsafeMutableRawBufferPointer(start: buffer, count: count)
        _ = bytes.withUnsafeBufferPointer { bytes in
            bytes.copyBytes(to: buffer)
        }
        bytes.removeFirst(count)
        return count
    }
}

class OutputByteStream: OutputStream {
    var bytes: [UInt8]

    override var hasSpaceAvailable: Bool { true }

    init() {
        bytes = .init()
        super.init(toMemory: ())
    }

    override func write(
        _ buffer: UnsafePointer<UInt8>,
        maxLength len: Int
    ) -> Int {
        let buffer = UnsafeBufferPointer<UInt8>(start: buffer, count: len)
        bytes.append(contentsOf: [UInt8](buffer))
        return len
    }
}
