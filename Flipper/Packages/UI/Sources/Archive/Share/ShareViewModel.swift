import Core
import Inject
import Analytics
import SwiftUI
import Combine
import CryptoKit

@MainActor
class ShareViewModel: ObservableObject {
    @Inject var analytics: Analytics

    let item: ArchiveItem
    let isTempLink: Bool
    @Published var state: State = .select

    enum State {
        case select
        case uploading
    }

    var name: String {
        "\(item.name.value).\(item.kind.extension)"
    }

    init(item: ArchiveItem) {
        self.item = item
        do {
            let url = try makeShareURL(for: item)
            self.isTempLink = url.count > 200
        } catch {
            self.isTempLink = true
        }
    }

    func share() {
        isTempLink
            ? shareAsTempLink()
            : shareAsShortLink()
    }

    func shareAsTempLink() {
        withAnimation {
            state = .uploading
        }
        Task {
            do {
                if let url = try await TempLinkSharing().shareKey(item) {
                    Core.share([url])
                }
            } catch {
                print(error)
            }
        }
    }

    func shareAsShortLink() {
        try? Core.shareAsURL(item)
        recordShare()
    }

    func shareAsFile() {
        Core.shareAsFile(item)
        recordShare()
    }

    func recordShare() {
        analytics.appOpen(target: .keyShare)
    }
}
