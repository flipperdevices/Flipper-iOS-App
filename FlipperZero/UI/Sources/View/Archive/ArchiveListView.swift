import Core
import SwiftUI

struct ArchiveListView: View {
    var items: [ArchiveItem]
    let isSynchronizing: Bool
    @State var syncLabelOpacity = 0.0
    @Binding var isSelectItemsMode: Bool
    @Binding var selectedItems: [ArchiveItem]

    var onAction: (Action) -> Void

    enum Action {
        case itemSelected(ArchiveItem)
        case horizontalDrag(Double)
        case synchronize
    }

    init(
        items: [ArchiveItem],
        isSynchronizing: Bool,
        isSelectItemsMode: Binding<Bool>,
        selectedItems: Binding<[ArchiveItem]>,
        onAction: @escaping (Action) -> Void
    ) {
        self.items = items
        self.isSynchronizing = isSynchronizing
        self._isSelectItemsMode = isSelectItemsMode
        self._selectedItems = selectedItems
        self.onAction = onAction
    }

    var body: some View {
        ScrollView {
            HStack {
                Spacer()
                ZStack {
                    Text("Keep pulling to sync with device")
                        .opacity(isSynchronizing ? 0 : 1)
                    Text("Syncing")
                        .opacity(isSynchronizing ? 1 : 0)
                }
                Spacer()
            }
            .foregroundColor(.secondary)
            .opacity(syncLabelOpacity)
            .padding(.top, -30)
            .animation(.spring())

            VStack(spacing: 12) {
                ForEach(items) { item in
                    Button {
                        onAction(.itemSelected(item))
                    } label: {
                        HStack {
                            if isSelectItemsMode {
                                Image(systemName: selectedItems.contains(item)
                                    ? "checkmark.circle.fill"
                                    : "circle"
                                )
                                .padding(.trailing, 8)
                            }
                            ArchiveListItemView(item: item)
                                .foregroundColor(.primary)
                                .background(systemBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .gesture(
                                    DragGesture()
                                        .onEnded { value in
                                            let width = value.translation.width
                                            onAction(.horizontalDrag(width))
                                        }
                                )
                        }
                    }
                }
            }
            .padding(.bottom, 12)
            .padding(.leading, 16)
            .padding(.trailing, 15)
            .background(GeometryReader {
                Color.clear.preference(
                    key: ViewOffsetKey.self,
                    value: $0.frame(in: .global).origin.y)
            })
            .onPreferenceChange(ViewOffsetKey.self, perform: onScroll)
        }
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
    }

    func onScroll(offset: Double) {
        switch offset - (UIDevice.isFaceIDAvailable ? 30 : 0) {
        case 222...: onAction(.synchronize)
        case 170...: syncLabelOpacity = 1
        default: syncLabelOpacity = 0
        }
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

            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text(item.origin)
                    .fontWeight(.thin)
            }

            Spacer()

            VStack {
                Spacer()
                Image(systemName: randomImage())
                    .font(.system(size: 14))
                    .padding(.trailing, 15)
                    .foregroundColor(.secondary)
                    .opacity(0)
                Spacer()
            }
        }
    }

    func randomImage() -> String {
        ["checkmark", "arrow.triangle.2.circlepath"].randomElement() ?? ""
    }

    func randomOpacity() -> Double {
        [true, false, true].randomElement() ?? false ? 1 : 0
    }
}
