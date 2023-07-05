struct FFFKeyedDecodingContainer<K : CodingKey>
: KeyedDecodingContainerProtocol {
    var codingPath: [CodingKey] { [] }

    var allKeys: [K] { properties.keys.compactMap(Key.init) }

    let properties: [String: String]

    init(_ properties: [String : String]) {
        self.properties = properties
    }

    private func value(for key: K) -> String {
        properties[key.stringValue]!
    }

    func contains(_ key: K) -> Bool {
        properties.keys.contains(key.stringValue)
    }

    func decodeNil(forKey key: K) throws -> Bool {
        true
    }

    func decode(_ type: Bool.Type, forKey key: K) throws -> Bool {
        .init(value(for: key))!
    }

    func decode(_ type: String.Type, forKey key: K) throws -> String {
        value(for: key)
    }

    func decode(_ type: Double.Type, forKey key: K) throws -> Double {
        .init(value(for: key))!
    }

    func decode(_ type: Float.Type, forKey key: K) throws -> Float {
        .init(value(for: key))!
    }

    func decode(_ type: Int.Type, forKey key: K) throws -> Int {
        .init(value(for: key))!
    }

    func decode(_ type: Int8.Type, forKey key: K) throws -> Int8 {
        .init(value(for: key))!
    }

    func decode(_ type: Int16.Type, forKey key: K) throws -> Int16 {
        .init(value(for: key))!
    }

    func decode(_ type: Int32.Type, forKey key: K) throws -> Int32 {
        .init(value(for: key))!
    }

    func decode(_ type: Int64.Type, forKey key: K) throws -> Int64 {
        .init(value(for: key))!
    }

    func decode(_ type: UInt.Type, forKey key: K) throws -> UInt {
        .init(value(for: key))!
    }

    func decode(_ type: UInt8.Type, forKey key: K) throws -> UInt8 {
        .init(value(for: key))!
    }

    func decode(_ type: UInt16.Type, forKey key: K) throws -> UInt16 {
        .init(value(for: key))!
    }

    func decode(_ type: UInt32.Type, forKey key: K) throws -> UInt32 {
        .init(value(for: key))!
    }

    func decode(_ type: UInt64.Type, forKey key: K) throws -> UInt64 {
        .init(value(for: key))!
    }

    func decode<T>(
        _ type: T.Type,
        forKey key: K
    ) throws -> T where T : Decodable {
        fatalError("not implemented")
    }

    func nestedContainer<NestedKey>(
        keyedBy type: NestedKey.Type,
        forKey key: K
    ) throws -> KeyedDecodingContainer<
        NestedKey
    > where NestedKey : CodingKey {
        fatalError("not implemented")
    }

    func nestedUnkeyedContainer(
        forKey key: K
    ) throws -> UnkeyedDecodingContainer {
        fatalError("not implemented")
    }

    func superDecoder() throws -> Decoder {
        fatalError("not implemented")
    }

    func superDecoder(forKey key: K) throws -> Decoder {
        fatalError("not implemented")
    }
}
