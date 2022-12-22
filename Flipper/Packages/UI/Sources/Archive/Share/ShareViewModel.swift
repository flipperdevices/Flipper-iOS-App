import Core
import Inject
import Logging
import Analytics
import SwiftUI
import Combine
import Network
import CryptoKit

@MainActor
class ShareViewModel: ObservableObject {
    private let logger = Logger(label: "share-vm")

    @Inject var analytics: Analytics

    let item: ArchiveItem
    let isTempLink: Bool
    @Published var state: State = .select

    enum State {
        case select
        case uploading
        case noInternet
        case cantConnect
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
        monitorNetworkStatus()
    }

    func monitorNetworkStatus() {
        let monitor = NWPathMonitor()
        var lastStatus: NWPath.Status?
        monitor.pathUpdateHandler = { [weak self] path in
            guard lastStatus != path.status else { return }
            self?.onNetworkStatusChanged(path.status)
            lastStatus = path.status
        }
        monitor.start(queue: .main)
    }

    func onNetworkStatusChanged(_ status: NWPath.Status) {
        if status == .unsatisfied {
            self.state = .noInternet
        } else {
            self.state = .select
        }
    }

    func retry() {
        self.state = .select
    }

    func shareAsTempLink() {
        withAnimation {
            state = .uploading
        }
        Task {
            do {
                if let url = try await TempLinkSharing().shareKey(item) {
                    Core.share([url])
                    analytics.appOpen(target: .keyShareUpload)
                }
            } catch {
                state = .cantConnect
                logger.error("sharing: \(error)")
            }
        }
    }

    func shareAsShortLink() {
        try? Core.shareAsURL(item)
        analytics.appOpen(target: .keyShareURL)
    }

    func shareAsFile() {
        Core.shareAsFile(item)
        analytics.appOpen(target: .keyShareFile)
    }

    func recordShare() {
        analytics.appOpen(target: .keyShare)
    }
}
