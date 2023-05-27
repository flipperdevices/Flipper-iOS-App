import SwiftUI

extension ImportView {
    struct ExpiredLinkError: View {
        var body: some View {
            VStack(spacing: 8) {
                Image("SharingExpiredLink")
                    .resizable()
                    .frame(width: 101, height: 60)

                VStack(spacing: 4) {
                    Text("Expired Link")
                        .font(.system(size: 14, weight: .medium))
                    Text("Unable to import file from this link")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black30)
                }
            }
        }
    }
}
