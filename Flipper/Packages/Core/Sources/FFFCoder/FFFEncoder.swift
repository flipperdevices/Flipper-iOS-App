struct FFFEncoder {
    static func encode<T: Encodable>(_ value: T) throws -> String {
        let encoder = _FFFEncoder()
        try value.encode(to: encoder)
        return encoder.result
    }
}

class _FFFEncoder: Encoder {
    var codingPath: [CodingKey] { [] }
    var userInfo: [CodingUserInfoKey : Any] { [:] }

    var result: String = ""

    func container<Key>(
        keyedBy type: Key.Type
    ) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = FFFKeyedEncodingContainer<Key>(encoder: self)
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError("unreachable")
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        fatalError("unreachable")
    }
}
