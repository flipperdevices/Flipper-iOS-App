struct FFFKeyedEncodingContainer<K: CodingKey>
: KeyedEncodingContainerProtocol {
    var codingPath: [CodingKey] { [] }

    var encoder: _FFFEncoder

    init(encoder: _FFFEncoder) {
        self.encoder = encoder
    }

    private mutating func append(_ value: String, for key: Key) {
        encoder.result += "\(key.stringValue): \(value)\n"
    }

    mutating func encodeNil(forKey key: K) throws {
        // ignore
    }

    mutating func encode(_ value: Bool, forKey key: K) throws {
        append("\(value)", for: key)
    }

    mutating func encode(_ value: String, forKey key: K) throws {
        append(value, for: key)
    }

    mutating func encode(_ value: Double, forKey key: K) throws {
        append("\(value)", for: key)
    }

    mutating func encode(_ value: Float, forKey key: K) throws {
        append("\(value)", for: key)
    }

    mutating func encode(_ value: Int, forKey key: K) throws {
        append("\(value)", for: key)
    }

    mutating func encode(_ value: Int8, forKey key: K) throws {
        append("\(value)", for: key)
    }

    mutating func encode(_ value: Int16, forKey key: K) throws {
        append("\(value)", for: key)
    }

    mutating func encode(_ value: Int32, forKey key: K) throws {
        append("\(value)", for: key)
    }

    mutating func encode(_ value: Int64, forKey key: K) throws {
        append("\(value)", for: key)
    }

    mutating func encode(_ value: UInt, forKey key: K) throws {
        append("\(value)", for: key)
    }

    mutating func encode(_ value: UInt8, forKey key: K) throws {
        append("\(value)", for: key)
    }

    mutating func encode(_ value: UInt16, forKey key: K) throws {
        append("\(value)", for: key)
    }

    mutating func encode(_ value: UInt32, forKey key: K) throws {
        append("\(value)", for: key)
    }

    mutating func encode(_ value: UInt64, forKey key: K) throws {
        append("\(value)", for: key)
    }

    mutating func encode<T>(
        _ value: T,
        forKey key: K
    ) throws where T: Encodable {
        fatalError("not implemented")
    }

    mutating func nestedContainer<NestedKey>(
        keyedBy keyType: NestedKey.Type,
        forKey key: K
    ) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        fatalError("not implemented")
    }

    mutating func nestedUnkeyedContainer(
        forKey key: K
    ) -> UnkeyedEncodingContainer {
        fatalError("not implemented")
    }

    mutating func superEncoder() -> Encoder {
        fatalError("unreachable")
    }

    mutating func superEncoder(forKey key: K) -> Encoder {
        fatalError("not implemented")
    }
}
