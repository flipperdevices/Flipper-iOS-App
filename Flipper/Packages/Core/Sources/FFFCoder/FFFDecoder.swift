class FFFDecoder {
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
    var userInfo: [CodingUserInfoKey : Any] { [:] }

    let dictionary: [String: String]

    init(text: String) {
        var dictionary = [String: String]()
        for line in text.split(separator: "\n") {
            let parts = line.split(separator: ":")
            guard parts.count == 2 else {
                continue
            }
            let key = String(parts[0]).trimmingCharacters(in: .whitespaces)
            let value = String(parts[1].dropFirst())
            dictionary[key] = value
        }
        self.dictionary = dictionary
    }

    init(dictionary: [String: String]) {
        self.dictionary = dictionary
    }

    func container<Key>(
        keyedBy type: Key.Type
    ) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
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
