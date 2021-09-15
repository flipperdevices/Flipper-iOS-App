import SwiftUI
import Core

struct CardSheetView: View {
    @Environment(\.colorScheme) var colorScheme
    let item: ArchiveItem

    var backgroundColor: Color { colorScheme == .light ? .white : .black }
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

            CardView(item: item)
                .foregroundColor(.white)
                .padding(.top, 5)
                .padding(.horizontal, 16)

            VStack(spacing: 0) {
                ForEach(Array(zip(item.actions.indices, item.actions)), id: \.0) { item in
                    if item.0 > 0 {
                        Divider()
                            .padding(0)
                    }
                    HStack {
                        Text(item.1.name)
                        Spacer()
                        item.1.icon
                    }
                    .padding(16)
                }
            }
            .background(backgroundColor)
            .foregroundColor(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(16)

            Divider()
            
            HStack(alignment: .top) {
                Image(systemName: "square.and.pencil")
                Spacer()
                Image(systemName: "square.and.arrow.up")
                Spacer()
                Image(systemName: "star")
                Spacer()
                Image(systemName: "trash")
            }
            .foregroundColor(Color.accentColor)
            .padding(.top, 20)
            .padding(.bottom, 60)
            .padding(.horizontal, 22)
        }
        .background(sheetBackgroundColor)
        .cornerRadius(12)
    }
}

struct CardView: View {
    let item: ArchiveItem

    var gradient: LinearGradient {
        .init(
            colors: [
                item.color,
                item.color2,
            ],
            startPoint: .top,
            endPoint: .bottom)
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(item.name)
                        .font(.system(size: 22).weight(.bold))
                    Spacer()
                    item.icon
                        .frame(width: 40, height: 40)
                }

                Text(item.description)
                    .font(.system(size: 20).weight(.semibold))
                Text(String(item.description.reversed()))
                    .font(.system(size: 20).weight(.semibold))

                HStack {
                    Text(item.origin)
                    Spacer()
                    Text(String(item.origin.reversed()))
                }

                HStack {
                    Image("cloud.checkmark")
                        .resizable()
                        .frame(width: 32, height: 24)
                    Spacer()
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
            .padding(16)
        }
        .background(gradient)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
