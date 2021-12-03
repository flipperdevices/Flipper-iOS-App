import SwiftUI

// swiftlint:disable function_default_parameter_at_end

struct CarouselView<Content: View, T: Identifiable>: View {
    var content: (T) -> Content
    var items: [T]

    let spacing: Double

    @GestureState var offset: Double = 0
    @Binding var index: Int

    init(
        spacing: Double = 20,
        index: Binding<Int>,
        items: [T],
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self.spacing = spacing
        self.items = items
        self._index = index
        self.content = content
    }

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: spacing) {
                ForEach(items) { item in
                    content(item)
                        .frame(width: proxy.size.width - spacing)
                }
            }
            .padding(.horizontal, spacing / 2)
            .offset(x: (Double(index) * -(proxy.size.width)) + offset)
            .simultaneousGesture(
                DragGesture()
                    .updating($offset) { value, state, _ in
                        state = value.translation.width
                    }
                    .onEnded { value in
                        let offset = value.translation.width
                        let progress = -(offset * 2) / proxy.size.width
                        let index = Int(progress.rounded())
                        self.index = max(min(self.index + index, items.count - 1), 0)
                    }
            )
        }
        .animation(.easeOut, value: offset == 0)
    }
}
