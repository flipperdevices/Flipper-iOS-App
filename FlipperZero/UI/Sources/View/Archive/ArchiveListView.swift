import Core
import SwiftUI

struct ArchiveListView: View {
    @Environment(\.colorScheme) var colorScheme
    var backgroundColor: Color { colorScheme == .light ? .white : .black }

    var itemSelected: (ArchiveItem) -> Void

    init(itemSelected: @escaping (ArchiveItem) -> Void ) {
        self.itemSelected = itemSelected
    }

    var body: some View {
        ScrollView {
            Spacer(minLength: 12)
            ForEach(demo) { item in
                Button {
                    itemSelected(item)
                } label: {
                    ArchiveListItemView(item: item)
                        .foregroundColor(.primary)
                        .background(backgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity)
        .padding(.leading, 16)
        .padding(.trailing, 15)
        .background(Color.gray.opacity(0.1))
    }
}

struct ArchiveListItemView: View {
    let item: ArchiveItem

    var body: some View {
        HStack(spacing: 15) {
            item.icon
                .resizable()
                .frame(width: 23, height: 23)
                .scaledToFit()
                .padding(.horizontal, 17)
                .padding(.vertical, 22)
                .background(item.color)
            VStack(spacing: 10) {
                HStack {
                    Text(item.name)
                        .bold()
                    if item.isFavorite {
                        Spacer()
                        Image(systemName: "star.fill")
                            .padding(.horizontal, 10)
                            .foregroundColor(.secondary)
                    }
                }

                HStack {
                    Text(item.description)
                    Spacer()
                    Text(item.origin)
                    Image("cloud.checkmark")
                        .padding(.horizontal, 10)
                }
            }
        }
    }
}

extension ArchiveItem {
    var icon: Image {
        switch kind {
        case .ibutton: return .init("ibutton")
        case .nfc: return .init("nfc")
        case .rfid: return .init("rfid")
        case .subghz: return .init("subhz")
        case .irda: return .init("irda")
        }
    }
}

extension ArchiveItem {
    var color: Color {
        switch kind {
        case .ibutton: return .init(red: 0.0, green: 0.48, blue: 1.0)
        case .nfc: return .init(red: 0.2, green: 0.78, blue: 0.64)
        case .rfid: return .init(red: 0.35, green: 0.34, blue: 0.84)
        case .subghz: return .init(red: 1.0, green: 0.61, blue: 0.2)
        case .irda: return .init(red: 0.69, green: 0.32, blue: 0.87)
        }
    }
}
