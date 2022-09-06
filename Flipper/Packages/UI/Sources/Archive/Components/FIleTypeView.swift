import Core
import SwiftUI

struct FileTypeView: View {
    let kind: ArchiveItem.Kind
    let isDeleted: Bool

    init(_ kind: ArchiveItem.Kind, isDeleted: Bool = false) {
        self.kind = kind
        self.isDeleted = isDeleted
    }

    var body: some View {
        HStack(spacing: 0) {
            kind.icon
                .resizable()
                .renderingMode(.template)
                .frame(width: 22, height: 22)
                .padding(.horizontal, 8)

            Text(kind.name)
                .font(.system(size: 14, weight: .medium))

            Spacer()
        }
        .frame(width: 110, height: 40)
        .foregroundColor(.black)
        .background(isDeleted ? Color.black4 : kind.color)
        .cornerRadius(18, corners: [.bottomRight])
    }
}
