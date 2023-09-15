import SwiftUI

struct AppsNoInternetView: View {
    var retry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 4) {
                Image("NoInternet")

                Text("No Internet Connection")
                    .font(.system(size: 12, weight: .bold))
                    .multilineTextAlignment(.center)

                Text("Turn on mobile data or Wi-Fi to access the Apps")
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
