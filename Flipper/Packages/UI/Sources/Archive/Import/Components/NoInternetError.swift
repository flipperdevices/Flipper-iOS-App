import SwiftUI

extension ImportView {
    struct NoInternetError: View {
        var action: () -> Void

        var body: some View {
            VStack(spacing: 8) {
                Image("SharingNoInternet")
                    .resizable()
                    .frame(width: 104, height: 60)

                VStack(spacing: 6) {
                    Text("No Internet Connection")
                        .font(.system(size: 14, weight: .medium))
                    Text("Unable to download this key")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black30)
                }

                Button {
                    action()
                } label: {
                    Text("Retry")
                        .font(.system(size: 16, weight: .medium))
                }
                .padding(.top, 4)
            }
        }
    }
}
