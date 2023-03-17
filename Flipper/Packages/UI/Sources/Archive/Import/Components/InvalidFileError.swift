import SwiftUI

extension ImportView {
    struct InvalidFileError: View {
        var body: some View {
            VStack(spacing: 8) {
                Image("SharingInvalidFile")
                    .resizable()
                    .frame(width: 115, height: 86)

                VStack(spacing: 4) {
                    Text("Invalid File Format")
                        .font(.system(size: 14, weight: .medium))
                    Text("Unable to import this file")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black30)
                }
            }
        }
    }
}
