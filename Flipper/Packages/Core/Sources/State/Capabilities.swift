public struct Capabilities {
    private let protobufVersion: ProtobufVersion

    public var canPlayAlert: Bool {
        switch protobufVersion {
        case .v1: return true
        default: return false
        }
    }

    init?(_ protobufVersion: ProtobufVersion?) {
        guard let protobufVersion = protobufVersion else {
            return nil
        }
        self.protobufVersion = protobufVersion
    }
}
