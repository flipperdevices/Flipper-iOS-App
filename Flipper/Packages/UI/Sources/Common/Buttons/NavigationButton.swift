import SwiftUI

struct NavigationButton<Destination: View>: View {
    let image: String
    let title: String
    let destination: () -> Destination

    init(
        image: String,
        title: String,
        @ViewBuilder destination: @escaping () -> Destination
    ) {
        self.image = image
        self.title = title
        self.destination = destination
    }

    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Image(image)
                    .renderingMode(.template)
                    .foregroundColor(.primary)
                    .padding(.leading, 12)

                Text(title)
                    .foregroundColor(.primary)
                    .font(.system(size: 14, weight: .medium))

                Spacer()

                Image("ChevronRight")
                    .padding(.trailing, 9)
            }
            .frame(height: 42)
            .frame(maxWidth: .infinity)
            .background(Color.groupedBackground)
        }
    }
}
