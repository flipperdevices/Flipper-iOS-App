import Infrared

public enum InfraredKeyID {
    case name(InfraredNameKeyID)
    case sha256(InfraredSHA256KeyID)
    case md5(InfraredMD5KeyID)
    case unknown

    init(_ keyId: Infrared.KeyID) {
        switch keyId {
        case .name(let nameIdKey):
            self = .name(InfraredNameKeyID(nameIdKey))
        case .sha256(let sha256IdKey):
            self = .sha256(InfraredSHA256KeyID(sha256IdKey))
        case .md5(let md5IdKey):
            self = .md5(InfraredMD5KeyID(md5IdKey))
        case .unknown:
            self = .unknown
        }
    }
}

public struct InfraredNameKeyID {
    public let name: String

    init(_ nameIdKey: Infrared.NameKeyIDType) {
        self.name = nameIdKey.name
    }
}

public struct InfraredSHA256KeyID {
    public let name: String
    public let hash: String

    init(_ sha256IdKey: Infrared.SHA256KeyIDType) {
        self.name = sha256IdKey.name
        self.hash = sha256IdKey.hash
    }
}

public struct InfraredMD5KeyID {
    public let name: String
    public let hash: String

    init(_ md5IdKey: Infrared.MD5KeyIDType) {
        self.name = md5IdKey.name
        self.hash = md5IdKey.hash
    }
}
