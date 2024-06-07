import SwiftUI

struct NavigationCard: View {
    let name: String
    let description: String
    let image: String
    let hasNotification: Bool

    init(
        name: String,
        description: String,
        image: String,
        hasNotification: Bool = false
    ) {
        self.name = name
        self.description = description
        self.image = image
        self.hasNotification = hasNotification
    }

    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 0) {
                    HStack(spacing: 8) {
                        Image(image)
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 30, height: 30)
                            .foregroundColor(.primary)

                        Text(name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                    }

                    Spacer(minLength: 8)

                    HStack(spacing: 2) {
                        if hasNotification {
                            Circle()
                                .frame(width: 14, height: 14)
                                .foregroundColor(.sGreenUpdate)
                        }

                        Image("ChevronRight")
                            .resizable()
                            .frame(width: 14, height: 14)
                    }
                }

                Text(description)
                    .font(.system(size: 12, weight: .medium))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.black30)
            }
            .padding(12)
        }
        .background(Color.groupedBackground)
        .cornerRadius(10)
    }
}
