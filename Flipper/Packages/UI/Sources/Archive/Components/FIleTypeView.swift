import Core
import SwiftUI

struct FileTypeView: View {
    let fileType: ArchiveItem.FileType
    let isDeleted: Bool

    init(_ fileType: ArchiveItem.FileType, isDeleted: Bool = false) {
        self.fileType = fileType
        self.isDeleted = isDeleted
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
        .background(isDeleted ? Color.black4 : fileType.color)
        .cornerRadius(18, corners: [.bottomRight])
    }
}
