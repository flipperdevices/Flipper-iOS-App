import Core
import SwiftUI

struct CategoryItem: View {
    let item: ArchiveItem

    var isDeleted: Bool {
        item.status == .deleted
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                FileTypeView(item.fileType, isDeleted: isDeleted)
                Text(item.info)
                    .padding(.top, 14)
                    .padding(.leading, 14)
                    .foregroundColor(.black12)
                    .font(.system(size: 12, weight: .medium))
                Spacer()
                item.status.image
                    .padding([.top, .trailing], 8)
                    .opacity(isDeleted ? 0 : 1)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(item.name.value)
                    .lineLimit(1)
                    .font(.system(size: 14, weight: .medium))

                if !item.note.isEmpty {
                    Text(item.note)
                        .lineLimit(1)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.black30)
                }
            }
            .padding(.horizontal, 8)
            .frame(maxHeight: .infinity)
        }
        .frame(height: 93)
        .background(Color.groupedBackground)
        .cornerRadius(10)
        .compositingGroup()
        .shadow(color: .shadow, radius: 16, x: 0, y: 4)
    }
}

fileprivate extension ArchiveItem {
    var info: String {
        switch fileType {
        case .subghz: return self["Protocol"] ?? ""
        case .rfid: return self["Key type"] ?? ""
        case .nfc: return self["Device type"] ?? ""
        case .infrared: return self["protocol"] ?? ""
        case .ibutton: return self["Key type"] ?? ""
        }
    }
}
