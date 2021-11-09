import Core
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

func share(_ key: ArchiveItem) {
    let urls = FileManager.default.urls(
        for: .cachesDirectory, in: .userDomainMask)

    guard let publicDirectory = urls.first else {
        return
    }

    let fileURL = publicDirectory
        .appendingPathComponent(key.name)
        .appendingPathExtension(key.kind.fileExtension)

    FileManager.default.createFile(
        atPath: fileURL.path,
        contents: key.description.data(using: .utf8))

    share([fileURL]) {_, _, _, _ in
        try? FileManager.default.removeItem(at: fileURL)
    }
}
