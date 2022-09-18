import Foundation

public func shareLogs(name: String, messages: [String]) {
    share(messages.joined(separator: "\n"), filename: "\(name).txt")
}
