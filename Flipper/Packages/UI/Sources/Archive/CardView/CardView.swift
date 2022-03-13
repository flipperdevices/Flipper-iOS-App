import Core
import SwiftUI

struct CardView: View {
    let item: ArchiveItem
    let kind: Kind

    enum Kind {
        case inspecting
        case importing
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                FileTypeView(item.fileType)
                Spacer()
                VStack(spacing: 2) {
                    Image("synced")
                    Text("Synced")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.accentColor)
                }
                .padding([.top, .trailing], 6)
                .opacity(kind == .inspecting ? 1 : 0)
            }

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Text(item.name.value)
                        .font(.system(size: 16, weight: .bold))
                        .lineLimit(1)

                    Image(systemName: item.isFavorite ? "star.fill" : "star")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.yellow)
                        .opacity(kind == .inspecting ? 1 : 0)
                }

                if item.description.isEmpty {
                    Text("Note is empty")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black30)
                        .italic()
                } else {
                    Text(item.description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black30)
                        .lineLimit(1)
                }
            }
            .padding(.top, 21)
            .padding(.horizontal, 12)

            Divider()
                .padding(.top, 18)

            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Key Type:")
                        .foregroundColor(.black30)

                    Text("EM-Marin")
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Data:")
                        .foregroundColor(.black30)

                    Text("DC 69 66 0F 12")
                }
            }
            .font(.system(size: 14, weight: .medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 18)
        }
        .background(Color.groupedBackground)
        .cornerRadius(16)
        .shadow(color: .shadow, radius: 16, x: 0, y: 4)
    }
}

extension ArchiveItem {
    var description: String {
        ""
    }
}
