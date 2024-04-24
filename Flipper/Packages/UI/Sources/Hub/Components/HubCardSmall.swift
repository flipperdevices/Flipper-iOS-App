import SwiftUI

struct HubCardSmall: View {
    let name: String
    let description: String
    let image: String
    let hasNotification: Bool

    var body: some View {
        HubCard {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(image)
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 30, height: 30)
                            .foregroundColor(.primary)

                        Spacer(minLength: 8)

                        HStack(spacing: 2) {
                            Circle()
                                .frame(width: 14, height: 14)
                                .foregroundColor(.sGreenUpdate)
                                .opacity(hasNotification ? 1 : 0)

                            Image("ChevronRight")
                                .resizable()
                                .frame(width: 14, height: 14)
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)

                        Text(description)
                            .font(.system(size: 12, weight: .medium))
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.black30)
                    }
                }

                Spacer(minLength: 0)
            }
        }
    }
}
