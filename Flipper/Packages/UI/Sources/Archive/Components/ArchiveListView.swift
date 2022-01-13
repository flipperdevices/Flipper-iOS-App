import Core
import SwiftUI

struct ArchiveListView: View {
    var items: [ArchiveItem]
    let hasFavorites: Bool
    let status: Status
    @State var showFavorites = true
    @State var syncLabelOpacity = 0.0
    @State var blockSelection = false
    @Binding var isSelectItemsMode: Bool
    @Binding var selectedItems: [ArchiveItem]

    var onAction: (Action) -> Void

    enum Action {
        case itemSelected(ArchiveItem)
        case synchronize
    }

    init(
        status: Status,
        items: [ArchiveItem],
        hasFavorites: Bool,
        isSelectItemsMode: Binding<Bool>,
        selectedItems: Binding<[ArchiveItem]>,
        onAction: @escaping (Action) -> Void
    ) {
        self.status = status
        self.items = items
        self.hasFavorites = hasFavorites
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
                        .opacity(status == .connected ? 1 : 0)
                        .opacity(status == .synchronizing ? 0 : 1)
                    Text("Syncing")
                        .opacity(status == .synchronizing ? 1 : 0)
                }
                Spacer()
            }
            .foregroundColor(.secondary)
            .opacity(syncLabelOpacity)
            .padding(.top, -30)
            .animation(.spring())

            VStack(alignment: .leading, spacing: 12) {
                if hasFavorites {
                    HStack {
                        Text("Favorites")
                            .font(.system(size: 28, weight: .bold))
                        Spacer()
                        Image(systemName: "chevron.up")
                            .font(.system(size: 22))
                            .rotationEffect(.degrees(showFavorites ? 0 : 180))
                    }
                    .background(systemBackground.opacity(0.01))
                    .padding(.horizontal, 32)
                    .onTapGesture {
                        withAnimation {
                            showFavorites.toggle()
                        }
                    }

                    if showFavorites {
                        list(items.filter { $0.isFavorite })
                    }

                    Text("All")
                        .font(.system(size: 28, weight: .bold))
                        .padding(.horizontal, 32)
                        .padding(.vertical, 8)
                }

                list(items)
            }
            .padding(.bottom, 12)
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

    func list(_ items: [ArchiveItem]) -> some View {
        ForEach(items) { item in
            Button {
                if !blockSelection {
                    onAction(.itemSelected(item))
                }
            } label: {
                HStack(spacing: 0) {
                    if isSelectItemsMode {
                        Image(systemName: selectedItems.contains(item)
                            ? "checkmark.circle.fill"
                            : "circle"
                        )
                        .padding(.trailing, 6)
                    }
                    ArchiveListItemView(item: item)
                        .foregroundColor(.primary)
                        .background(systemBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let height = abs(value.translation.height)
                                    let width = abs(value.translation.width)
                                    blockSelection = width > height
                                }
                                .onEnded { _ in
                                    blockSelection = false
                                }
                        )
                }
            }
            .padding(.leading, isSelectItemsMode ? 5 : 16)
            .padding(.trailing, isSelectItemsMode ? 0 : 16)
        }
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
                Text(item.name.value)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text(item.fileType.extension)
                    .fontWeight(.thin)
            }

            Spacer()

            VStack {
                Spacer()
                Image(systemName: item.status.systemImageName)
                    .font(.system(size: 14))
                    .padding(.trailing, 15)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
    }
}

extension ArchiveItem.Status {
    var systemImageName: String {
        switch self {
        case .error: return "xmark.octagon"
        case .deleted: return "trash"
        case .imported: return "clock.arrow.2.circlepath"
        case .modified: return "clock.arrow.2.circlepath"
        case .synchronizied: return "checkmark"
        case .synchronizing: return "arrow.triangle.2.circlepath"
        }
    }
}
