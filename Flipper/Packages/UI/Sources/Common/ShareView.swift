import Core
import Logging
import SwiftUI

func share(
    _ items: [Any],
    completion: UIActivityViewController.CompletionWithItemsHandler? = nil
) {
    let activityContoller = UIActivityViewController(
        activityItems: items,
        applicationActivities: nil)
    activityContoller.completionWithItemsHandler = completion

    UIApplication.shared
        .windows
        .first?
        .rootViewController?
        .present(activityContoller, animated: true, completion: nil)
}

enum ShareOption {
    case file
    case scheme
}

func share(_ key: ArchiveItem, shareOption: ShareOption) {
    switch shareOption {
    case .file: shareFile(key)
    case .scheme: shareScheme(key)
    }
}

func shareScheme(_ key: ArchiveItem) {
    guard let data = key.content.data(using: .utf8) else {
        Logger(label: "share").error("invalid description")
        return
    }
    let base64String = data.base64EncodedString()
    let urlString = "flipper://\(key.fileName)/\(base64String)"
    share([urlString])
}

func shareFile(_ key: ArchiveItem) {
    let urls = FileManager.default.urls(
        for: .cachesDirectory, in: .userDomainMask)

    guard let publicDirectory = urls.first else {
        return
    }

    let fileURL = publicDirectory.appendingPathComponent(key.fileName)

    FileManager.default.createFile(
        atPath: fileURL.path,
        contents: key.content.data(using: .utf8))

    share([fileURL]) {_, _, _, _ in
        try? FileManager.default.removeItem(at: fileURL)
    }
}

func shareLogs(name: String, messages: [String]) {
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
