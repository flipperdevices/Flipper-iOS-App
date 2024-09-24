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
        guard
            let data = try? JSONEncoder().encode(self),
            let content = String(data: data, encoding: .utf8)
        else { return "[]" }
        return content
    }
}
