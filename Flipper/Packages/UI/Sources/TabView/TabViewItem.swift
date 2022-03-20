import SwiftUI

struct TabViewItem: View {
    let image: AnyView
    let name: String
    let isSelected: Bool
    let onItemSelected: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                image
                    .padding(.top, 6)
                Text(name)
                    .font(.system(size: 10, weight: .bold))
                    .padding(.bottom, 4)
                    .padding(.horizontal, 12)
            }
            .background(isSelected ? Color.black4 : Color.clear)
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 46)
        .onTapGesture {
            onItemSelected()
        }
    }
}
