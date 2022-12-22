import SwiftUI

struct ShareView: View {
    @StateObject var viewModel: ShareViewModel

    var body: some View {
        VStack {
            VStack(spacing: 2) {
                Text("Share")
                    .font(.system(size: 14, weight: .medium))

                Text(viewModel.name)
                    .font(.system(size: 18, weight: .medium))
            }
            .padding(.top, 4)

            VStack {
                switch viewModel.state {
                case .noInternet:
                    NoInternetError()
                case .cantConnect:
                    CantConnectError {
                        viewModel.retry()
                    }
                case .select:
                    HStack(alignment: .top) {
                        Spacer()
                        ShareAsLinkButton(isTempLink: viewModel.isTempLink) {
                            viewModel.isTempLink
                                ? viewModel.shareAsTempLink()
                                : viewModel.shareAsShortLink()
                        }
                        Spacer()
                        ShareAsFile {
                            viewModel.shareAsFile()
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
        .onAppear {
            viewModel.recordShare()
        }
    }

    struct ShareAsLinkButton: View {
        let isTempLink: Bool
        var action: () -> Void

        var body: some View {
            Button {
                action()
            } label: {
                VStack(spacing: 12) {
                    Image("ShareAsLink")
                    VStack(spacing: 2) {
                        Text("via Secure Link")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.a1)
                        Text("Expires in 30 days")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.black30)
                            .opacity(isTempLink ? 1 : 0)
                    }
                }
            }
        }
    }

    struct ShareAsFile: View {
        var action: () -> Void

        var body: some View {
            Button {
                action()
            } label: {
                VStack(spacing: 12) {
                    Image("ShareAsFile")
                    Text("Export File")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.a1)
                }
            }
        }
    }

    struct NoInternetError: View {
        var body: some View {
            VStack(spacing: 2) {
                Image("SharingNoInternet")
                    .resizable()
                    .frame(width: 83, height: 48)
                Text("No Internet Connection")
                    .font(.system(size: 14, weight: .medium))
                Text("Unable to share this link")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black40)
            }
        }
    }

    struct CantConnectError: View {
        var action: () -> Void

        var body: some View {
            VStack(spacing: 2) {
                Image("SharingCantConnect")
                    .resizable()
                    .frame(width: 84, height: 48)
                Text("Can't Connect to the Server")
                    .font(.system(size: 14, weight: .medium))
                Text("Unable to share this link")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black40)
                Button {
                    action()
                } label: {
                    Text("Retry")
                        .font(.system(size: 16, weight: .medium))
                }
            }
        }
    }
}
