import Core
import SwiftUI

struct ShareView: View {
    @EnvironmentObject var sharingService: SharingService
    @EnvironmentObject var networkMonitor: NetworkMonitor

    let item: ArchiveItem

    @State private var state: SharingState = .select
    @State private var isTempLink = false

    enum SharingState {
        case select
        case uploading
        case noInternet
        case cantConnect
    }

    var body: some View {
        VStack {
            VStack(spacing: 2) {
                Text("Share")
                    .font(.system(size: 14, weight: .medium))

                Text(item.filename)
                    .font(.system(size: 18, weight: .medium))
            }
            .padding(.top, 4)

            VStack {
                switch state {
                case .noInternet:
                    NoInternetError()
                case .cantConnect:
                    CantConnectError {
                        retry()
                    }
                case .select:
                    HStack(alignment: .top) {
                        Spacer()
                        ShareAsLinkButton(isTempLink: isTempLink) {
                            isTempLink
                                ? shareAsTempLink()
                                : shareAsShortLink()
                        }
                        Spacer()
                        ShareAsFileButton {
                            shareAsFile()
                        }
                        Spacer()
                    }
                    .padding(.bottom, 64)
                case .uploading:
                    VStack(spacing: 18) {
                        Animation("Loading")
                            .frame(width: 42, height: 42)
                        VStack(spacing: 2) {
                            Text("via Secure Link")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.a1)
                            Text("Expires in 30 days")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.black30)
                        }
                    }
                }
            }
            .padding(.top, 42)

            Spacer()
        }
        .frame(height: 258)
        .onChange(of: networkMonitor.isAvailable) { available in
            state = available ? .select : .noInternet
        }
        .onAppear {
            sharingService.shareInitiated()
        }
        .task {
            isTempLink = !sharingService.canEncodeToURL(item)
        }
    }

    func retry() {
        state = .select
    }

    func shareAsTempLink() {
        withAnimation {
            state = .uploading
        }
        Task {
            do {
                try await sharingService.shareAsTempLink(item: item)
            } catch {
                state = .cantConnect
            }
        }
    }

    func shareAsShortLink() {
        sharingService.shareAsShortLink(item: item)
    }

    func shareAsFile() {
        sharingService.shareAsFile(item: item)
    }
}
