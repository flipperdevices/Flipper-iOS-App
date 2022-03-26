import Foundation

class ChunkedInput {
    var length: Int?
    var data: Data = .init()

    var isCompleteMessage: Bool {
        !data.isEmpty && length == data.count
    }

    func removeMessageData() {
        guard let length = length else { return }
        data.removeFirst(length)
        self.length = nil
    }

    func feed(_ chunk: Data) throws -> PB_Main? {
        defer {
            if isCompleteMessage { removeMessageData() }
        }
        data.append(contentsOf: chunk)
        if length == nil {
            length = try readLength()
        }
        return isCompleteMessage
            ? try .init(serializedData: data)
            : nil
    }

    func readLength() throws -> Int {
        var value = 0
        var shift = 0

        while true {
            guard !data.isEmpty else {
                throw ChunkedInputError.insufficientData
            }
            let c = data.removeFirst()
            value |= Int(c & 0x7f) << shift
            if c & 0x80 == 0 {
                return value
            }
            shift += 7
            if shift > 63 {
                throw ChunkedInputError.malformedProtobuf
            }
        }
    }
}

enum ChunkedInputError: Swift.Error {
    case malformedProtobuf
    case insufficientData
}
