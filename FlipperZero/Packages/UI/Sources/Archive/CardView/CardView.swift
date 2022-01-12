import Core
import SwiftUI

struct CardView: View {
    @Binding var name: String
    @Binding var item: ArchiveItem
    @Binding var isEditMode: Bool
    @Binding var focusedField: String

    @State var flipped = false
    @State var cardRotation = 0.0
    @State var contentRotation = 0.0

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
                CardHeaderView(
                    name: $name,
                    image: item.icon,
                    isEditMode: $isEditMode,
                    focusedField: $focusedField,
                    flipped: flipped
                )
                .padding(16)
                .opacity(flipped ? 0.4 : 1)

                CardDivider()

                CardDataView(
                    item: _item,
                    isEditMode: $isEditMode,
                    focusedField: $focusedField,
                    flipped: flipped
                )
                .rotation3DEffect(
                    .degrees(contentRotation), axis: (x: 0, y: 1, z: 0))

                HStack {
                    Spacer()
                    Image(systemName: item.status.systemImageName)
                        .opacity(flipped ? 0.3 : 1)
                    Spacer()
                }
                .padding(16)
            }
        }
        .background(gradient)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.bottom, 16)
        .rotation3DEffect(.degrees(cardRotation), axis: (x: 0, y: 1, z: 0))
        .simultaneousGesture(DragGesture()
            .onChanged { value in
                let width = value.translation.width
                if width < 0 && cardRotation > -180 {
                    cardRotation = max(value.translation.width, -180)
                } else if width > 0 && cardRotation < 0 {
                    cardRotation = min(0, value.translation.width - 180)
                }
                flipped = cardRotation < -90
                contentRotation = cardRotation < -90 ? -180 : 0
            }
            .onEnded { _ in
                if cardRotation < -90 {
                    cardRotation = -180
                } else {
                    cardRotation = 0
                }
            })
    }
}

struct CardDivider: View {
    var body: some View {
        Color.white
            .frame(height: 1)
            .opacity(0.3)
    }
}
