import Core
import SwiftUI

struct InfraredNetworkError: View {
    let error: InfraredModel.Error.Network
    let action: () -> Void

    var body: some View {
        switch error {
        case .invalidResponse: InvalidResponseView(retry: action)
        case .noInternet: NoInternetView(retry: action)
        }
    }
}

extension InfraredNetworkError {
    struct InvalidResponseView: View {
        let retry: () -> Void

        var body: some View {
            VStack(spacing: 12) {
                VStack(spacing: 4) {
                    Image("ServerError")

                    Text("Unable to get controls")
                        .font(.system(size: 12, weight: .bold))
                        .multilineTextAlignment(.center)

                    Text("Can’t connect to collection server")
                        .font(.system(size: 12, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black40)
                }

                Button {
                    retry()
                } label: {
                    Text("Retry")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.a2)
                }
            }
        }
    }

    struct NoInternetView: View {
        let retry: () -> Void

        var body: some View {
            VStack(spacing: 12) {
                VStack(spacing: 4) {
                    Image("NoInternet")

                    Text("No Internet Connection")
                        .font(.system(size: 12, weight: .bold))
                        .multilineTextAlignment(.center)

                    Text(
                        "Turn on mobile data or Wi-Fi\n" +
                         "to access infrared collection"
                    )
                    .font(.system(size: 12, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black40)
                }

                Button {
                    retry()
                } label: {
                    Text("Retry")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.a2)
                }
            }
        }
    }
}
