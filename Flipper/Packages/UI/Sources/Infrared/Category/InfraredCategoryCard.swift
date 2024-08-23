import Core
import SwiftUI

extension InfraredView {
    struct CategoryCard: View {
        let item: InfraredCategory
        let onItemSelected: () -> Void

        private var uiImage: UIImage? {
            let data = Data(base64Encoded: item.image) ?? Data()
            return UIImage(data: data)
        }

        var body: some View {
            VStack(spacing: 8) {
                if let uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 36, height: 36)
                }

                Text(item.name)
                    .font(.system(size: 18, weight: .regular))
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .foregroundColor(Color.primary)
            .background(Color.groupedBackground)
            .cornerRadius(16)
            .shadow(color: .shadow, radius: 16, x: 0, y: 4)
            .onTapGesture { onItemSelected() }
        }
    }
}
