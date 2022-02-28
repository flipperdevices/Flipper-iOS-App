import Foundation

public func shareLogs(name: String, messages: [String]) {
    let urls = FileManager.default.urls(
        for: .cachesDirectory, in: .userDomainMask)

    guard let publicDirectory = urls.first else {
        return
    }

    let fileURL = publicDirectory.appendingPathComponent("\(name).txt")
    let data = messages.joined(separator: "\n").data(using: .utf8)

    FileManager.default.createFile(atPath: fileURL.path, contents: data)

    share([fileURL]) {_, _, _, _ in
        try? FileManager.default.removeItem(at: fileURL)
    }
}
