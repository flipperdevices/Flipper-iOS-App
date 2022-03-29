protocol PlaintextCodable {
    init(decoding: String) throws
    func encode() throws -> String
}
