import SwiftUI

struct Banner<Action: View>: View {
    let image: String
    let title: String
    let description: String
    @ViewBuilder let action: () -> Action

    @Environment(\.colorScheme) var colorScheme

    var backgroundColor: Color {
        colorScheme == .light ? .black4 : .black80
    }

    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
                Image(image)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .lineLimit(1)
                        .font(.system(size: 12, weight: .bold))
                    Text(description)
                        .font(.system(size: 12, weight: .medium))
                }
                Spacer(minLength: 0)
                action()
                    .font(.system(size: 12, weight: .bold))
            }
            .padding(12)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(8)
        }
        .padding(12)
    }
}

extension Banner where Action == EmptyView {
    init(image: String, title: String, description: String) {
        self.image = image
        self.title = title
        self.description = description
        self.action = { EmptyView() }
    }
}
