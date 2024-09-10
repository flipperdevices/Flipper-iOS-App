import Foundation

extension Set: @retroactive RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        do {
            self = try JSONDecoder()
                .decode(Set<Element>.self, from: Data(rawValue.utf8))
        } catch {
            return nil
        }
    }

    public var rawValue: String {
        do {
            let data = try JSONEncoder().encode(self)
            return String(decoding: data, as: UTF8.self)
        } catch {
            return "[]"
        }
    }
}
