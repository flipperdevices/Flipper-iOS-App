import Infrared

public typealias InfraredKeyID = Infrared.InfraredKeyID

public extension InfraredKeyID {
    var name: String? {
        return switch self {
        case .name(let name):
            name.name
        case .sha256(let sha256):
            sha256.name
        case .md5(let md5):
            md5.name
        case .unknown:
            nil
        }
    }
}
