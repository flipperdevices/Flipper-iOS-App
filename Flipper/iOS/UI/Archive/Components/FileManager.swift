import SwiftUI

struct FileManagerSection: View {
    @Environment(\.isEnabled) var isEnabled

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image("FileManagerIcon")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.primary)

                Text("File Manager")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)

                Spacer()

                Image("ChevronRight")
                    .resizable()
                    .frame(width: 14, height: 14)
            }

            Text("Manage files and assets on your Flipper Zero")
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.leading)
                .foregroundColor(.black30)
        }
        .padding(12)
        .opacity(isEnabled ? 1 : 0.4)
        .background(Color.groupedBackground)
        .cornerRadius(12)
    }
}
