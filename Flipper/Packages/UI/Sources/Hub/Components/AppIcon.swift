import SwiftUI

struct AppIcon: View {
    let url: URL

    var body: some View {
        Group {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image
                        .renderingMode(.template)
                        .interpolation(.none)
                        .resizable()
                }
            }
            .foregroundColor(.black)
            .scaledToFit()
            .padding(4)
        }
        .background(Color.a1)
        .cornerRadius(6)
    }
}
