import Core
import SwiftUI

struct FileTypeView: View {
    let fileType: ArchiveItem.FileType

    init(_ fileType: ArchiveItem.FileType) {
        self.fileType = fileType
    }

    var body: some View {
        HStack(spacing: 0) {
            fileType.icon
                .resizable()
                .renderingMode(.template)
                .frame(width: 22, height: 22)
                .padding(.horizontal, 8)

            Text(fileType.name)
                .font(.system(size: 14, weight: .medium))

            Spacer()
        }
        .frame(width: 110, height: 40)
        .foregroundColor(.black)
        .background(fileType.color)
        .cornerRadius(18, corners: [.bottomRight])
    }
}
