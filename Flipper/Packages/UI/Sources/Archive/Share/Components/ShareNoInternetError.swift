import SwiftUI

extension ShareView {
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
}
