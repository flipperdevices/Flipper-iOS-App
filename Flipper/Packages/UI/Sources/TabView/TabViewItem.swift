import SwiftUI

struct TabViewItem: View {
    let image: String
    let name: String
    let isSelected: Bool
    let onItemSelected: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Image(image)
            Text(name)
                .font(.system(size: 10, weight: .bold))
                .padding(.top, 4)
        }
        .frame(width: 80, height: 46)
        .onTapGesture {
            onItemSelected()
        }
    }
}
