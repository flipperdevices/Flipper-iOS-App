import SwiftUI

struct HubCard<Content: View>: View {
    let icon: String
    let title: String

    let image: String
    let subtitle: String
    let description: String

    let badge: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                SmallImage(icon)
                    .foregroundColor(.primary)

                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)

                Spacer()

                HStack(spacing: 2) {
                    badge()

                    Image("ChevronRight")
                        .resizable()
                        .frame(width: 14, height: 14)
                }
            }

            HStack(spacing: 8) {
                Image(image)

                VStack(alignment: .leading, spacing: 2) {
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.primary)

                    Text(description)
                        .font(.system(size: 12, weight: .medium))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.black30)
                }

                Spacer()
            }
        }
        .padding([.bottom, .leading, .top], 12)
        .padding(.trailing, 8)
        .background(Color.groupedBackground)
        .cornerRadius(10)
    }
}
