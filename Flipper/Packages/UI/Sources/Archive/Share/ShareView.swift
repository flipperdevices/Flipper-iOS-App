import SwiftUI

struct ShareView: View {
    @StateObject var viewModel: ShareViewModel

    var body: some View {
        VStack {
            VStack(spacing: 2) {
                Text("Share")
                    .font(.system(size: 18, weight: .bold))

                Text(viewModel.name)
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(.top, 4)

            VStack {
                switch viewModel.state {
                case .select:
                    HStack(alignment: .top) {
                        Spacer()
                        ShareAsLinkButton(isTempLink: viewModel.isTempLink) {
                            viewModel.share()
                        }
                        Spacer()
                        ShareAsFile {
                            viewModel.shareAsFile()
                        }
                        Spacer()
                    }
                case .uploading:
                    VStack(spacing: 18) {
                        Animation("Loading")
                            .frame(width: 42, height: 42)
                        VStack(spacing: 2) {
                            Text("via Secure Link")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                            Text("Expires in 30 days")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.black30)
                        }
                    }
                }
            }
            .padding(.vertical, 42)
        }
        .background(.background)
        .cornerRadius(30, corners: [.topLeft, .topRight])
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
                            .foregroundColor(.primary)
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
                        .foregroundColor(.primary)
                }
            }
        }
    }
}
