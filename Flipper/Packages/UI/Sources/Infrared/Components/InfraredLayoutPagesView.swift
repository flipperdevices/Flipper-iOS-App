import SwiftUI
import Core

struct InfraredLayoutPagesView: View {
    let layout: InfraredLayout

    var body: some View {
        if layout.pages.isEmpty {
            EmptyLayout()
        } else {
            Pagination(pages: layout.pages)
        }
    }
}

extension InfraredLayoutPagesView {
    struct Pagination: View {
        let pages: [InfraredPageLayout]

        @State private var selectedIndex = 0

        var body: some View {
            VStack {
                SwiftUI.TabView(selection: $selectedIndex) {
                    ForEachIndexed(pages) { page, index in
                        InfraredLayoutPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                HStack {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(
                                index == selectedIndex
                                    ? Color.black60
                                    : Color.black12
                            )
                            .frame(width: 8, height: 8)
                            .animation(
                                .easeInOut(duration: 0.25),
                                value: selectedIndex
                            )
                    }
                }
                .padding(8)
                .opacity(pages.count > 1 ? 1 : 0)
            }
        }
    }

    struct EmptyLayout: View {
        @Environment(\.layoutState) private var layoutState

        var body: some View {
            switch layoutState {
            case .default:
                Text("Infrared layout is empty")
                    .font(.system(size: 16, weight: .medium))
            case .syncing, .disabled, .notSupported, .emulating:
                InfraredLayoutPageView(page: InfraredPageLayout.progressMock)
            }
        }
    }
}
