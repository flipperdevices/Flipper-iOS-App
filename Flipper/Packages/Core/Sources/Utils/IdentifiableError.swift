import Foundation

public struct IdentifiableError: Identifiable {
    public let id = UUID()
    let error: Error

    public init(from error: Error) {
        self.error = error
    }

    public var description: String {
        String(describing: error)
    }
}
