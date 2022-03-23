public struct Capabilities {
    private let protobufVersion: ProtobufVersion

    public var hasOTASupport: Bool {
        switch protobufVersion {
        default: return false
        }
    }

    init(_ protobufVersion: ProtobufVersion) {
        self.protobufVersion = protobufVersion
    }
}

extension Peripheral {
    var capatibilities: Capabilities {
        .init(.v0_2)
    }
}
