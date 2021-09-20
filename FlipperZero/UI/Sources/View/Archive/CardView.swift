import SwiftUI
import Core

struct CardSheetView: View {
    @Environment(\.colorScheme) var colorScheme
    let item: ArchiveItem

    var sheetBackgroundColor: Color {
        colorScheme == .light
            ? .init(red: 0.95, green: 0.95, blue: 0.97)
            : .init(red: 0.1, green: 0.1, blue: 0.1)
    }

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.gray)
                .frame(width: 40, height: 6)
                .padding(.vertical, 18)

            Card(item: item)
                .foregroundColor(.white)
                .padding(.top, 5)
                .padding(.horizontal, 16)

            CardDeviceActions(item: item)

            Divider()

            CardActions(item: item)
        }
        .background(sheetBackgroundColor)
        .cornerRadius(12)
    }
}

struct Card: View {
    let item: ArchiveItem

    var gradient: LinearGradient {
        .init(
            colors: [
                item.color,
                item.color2
            ],
            startPoint: .top,
            endPoint: .bottom)
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                CardHeaderView(name: item.name, image: item.icon)
                    .padding(16)

                CardDivider()

                CardDataView(item: item)
                    .padding(16)

                HStack {
                    Spacer()
                    Image(systemName: "checkmark")
                    Spacer()
                }
                .padding(.bottom, 16)
            }
        }
        .background(gradient)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct CardHeaderView: View {
    let name: String
    let image: Image

    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 22).weight(.bold))
            Spacer()
            image
                .frame(width: 40, height: 40)
        }
    }
}

struct CardDivider: View {
    var body: some View {
        Color.white
            .frame(height: 1)
            .opacity(0.3)
    }
}

struct CardDataView: View {
    let item: ArchiveItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !item.description.isEmpty {
                Text(item.description)
                    .font(.system(size: 20).weight(.semibold))
            }
            if !item.description.isEmpty {
                Text(String(item.description.reversed()))
                    .font(.system(size: 20).weight(.semibold))
            }

            if !item.origin.isEmpty {
                HStack {
                    Text(item.origin)
                    Spacer()
                    Text(String(item.origin.reversed()))
                }
            }
        }
    }
}

struct CardDeviceActions: View {
    @Environment(\.colorScheme) var colorScheme
    let item: ArchiveItem

    var backgroundColor: Color { colorScheme == .light ? .white : .black }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(zip(item.actions.indices, item.actions)), id: \.0) { item in
                if item.0 > 0 {
                    Divider()
                        .padding(0)
                }
                CardDeviceAction(action: item.1)
            }
        }
        .background(backgroundColor)
        .foregroundColor(Color.accentColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(16)
    }
}

struct CardDeviceAction: View {
    let action: ArchiveItem.Action

    var body: some View {
        HStack {
            Text(action.name)
                .font(.system(size: 16))
            Spacer()
            action.icon
                .font(.system(size: 22))
        }
        .padding(16)
    }
}

struct CardActions: View {
    let item: ArchiveItem

    var body: some View {
        HStack(alignment: .top) {

            // MARK: Edit

            Button {
            } label: {
                Image(systemName: "square.and.pencil")
            }

            Spacer()

            // MARK: Share

            Button {
            } label: {
                Image(systemName: "square.and.arrow.up")
            }

            Spacer()

            // MARK: Favorite

            Button {
            } label: {
                Image(systemName: "star")
            }

            Spacer()

            // MARK: Delete

            Button {
            } label: {
                Image(systemName: "trash")
            }

        }
        .font(.system(size: 22))
        .foregroundColor(Color.accentColor)
        .padding(.top, 20)
        .padding(.bottom, 45)
        .padding(.horizontal, 22)
    }
}
