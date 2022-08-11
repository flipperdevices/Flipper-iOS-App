import struct Foundation.UUID

enum SessionID {
    static var uuidString: String = {
        UUID().uuidString
    }()
}
