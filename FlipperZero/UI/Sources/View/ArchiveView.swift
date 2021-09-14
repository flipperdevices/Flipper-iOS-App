import Core
import SwiftUI

struct ArchiveView: View {
    @ObservedObject var viewModel: ArchiveViewModel
    @Environment(\.colorScheme) var colorScheme

    init(viewModel: ArchiveViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            navbar
            categories
            items

        }
    }

    // FIXME: iOS15 beta bug, use navbar
    var navbar: some View {
        HStack {
            Image(systemName: "ellipsis.circle")
                .resizable()
                .frame(width: 22, height: 22)
                .scaledToFit()
                .padding(.horizontal, 15)
                .foregroundColor(Color.accentColor)
            Spacer()
            // FIXME: Move out, replace images with code
            ZStack(alignment: .center) {
                Image(viewModel.device?.state == .connected ? "CurrentDevice" : "CurrentNoDevice")
                Text(viewModel.device?.name ?? "No device")
                    .bold()
                    .padding(.bottom, 5)
                    .foregroundColor(Color.primary.opacity(viewModel.device?.state == .connected ? 1 : 0.8))
            }
            Spacer()
            Button(action: { viewModel.readNFCTag() }) {
                Image(systemName: "plus.circle")
                    .resizable()
                    .frame(width: 22, height: 22)
                    .scaledToFit()
                    .padding(.horizontal, 15)
                    .foregroundColor(Color.accentColor)
            }
        }
        .frame(height: 44)
    }

    var categories: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(["Favorites", "RFID 125", "Sub-gHz", "NFC", "iButton", "iRda"], id: \.self) {
                    Text($0)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 12)
                        .foregroundColor(Color.secondary)
                }
            }
        }
        .padding(.horizontal, 10)
    }

    var items: some View {
        ScrollView {
            Spacer(minLength: 12)
            ForEach(demo) { item in
                ArchiveListItemView(item: item)
                    .background(colorScheme == .light ? Color.white : Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
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

struct ArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        ArchiveView(viewModel: .init())
    }
}

