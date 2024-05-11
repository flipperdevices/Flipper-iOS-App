class FFFDecoder {
    enum Error: Swift.Error {
        case notFound(String)
    }

    static func decode<T: Decodable>(
        _ type: T.Type,
        from string: String
    ) throws -> T {
        try .init(from: _FFFDecoder(text: string))
    }

    static func decode<T: Decodable>(
        _ type: T.Type,
        from bytes: [UInt8]
    ) throws -> T {
        try decode(type, from: .init(decoding: bytes, as: UTF8.self))
    }
}

class _FFFDecoder: Decoder {
    var codingPath: [CodingKey] { [] }
    var userInfo: [CodingUserInfoKey: Any] { [:] }

    let dictionary: [String: String]

    init(text: String) {
        // TODO: Improve decoder to support comments and reuse for ArchiveItem
        var dictionary = [String: String]()

        let lines = text.split { $0 == "\n" || $0 == "\r\n" }

        for line in lines {
            guard !line.starts(with: "#") else {
                continue
            }
            guard line.contains(":") else {
                continue
            }
            let keyValue = line.split(separator: ":", maxSplits: 1)
            let keyPart = keyValue[0]
            let valuePart = keyValue.count == 2 ? keyValue[1] : ""

            let key = String(keyPart.trimmingCharacters(in: .whitespaces))
            let value = String(valuePart.trimmingCharacters(in: .whitespaces))
            dictionary[key] = value
        }
        self.dictionary = dictionary
    }

    init(dictionary: [String: String]) {
        self.dictionary = dictionary
    }

    func container<Key>(
        keyedBy type: Key.Type
    ) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
        let container = FFFKeyedDecodingContainer<Key>(dictionary)
        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError("unreachable")
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        fatalError("unreachable")
    }
}

extension FFFDecoder.Error: CustomStringConvertible {
    var description: String {
        switch self {
        case .notFound(let key): return "value for key not found - '\(key)'"
        }
    }
}
