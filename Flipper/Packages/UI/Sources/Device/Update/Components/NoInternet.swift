import SwiftUI

extension DeviceUpdateView {
    struct NoInternetView: View {
        var retry: () -> Void

        var body: some View {
            VStack(spacing: 0) {
                Image("NoInternetAlert")

                Text("Unable to download firmware")
                    .font(.system(size: 14, weight: .medium))
                    .padding(.top, 6)

                Text("Can't connect to update server")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black30)
                    .padding(.top, 4)

                Button {
                    retry()
                } label: {
                    Text("Retry")
                        .font(.system(size: 16, weight: .medium))
                }
                .padding(.top, 12)
            }
            .padding(.horizontal, 24)
            .padding(.top, 38)
        }
    }
}
