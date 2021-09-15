import SwiftUI

struct PartialSheetView<SheetView: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isPresented: Bool
    let content: () -> SheetView

    var backgroundColor: Color { colorScheme == .light ? .white : .black }

    init(isPerented: Binding<Bool>, @ViewBuilder content: @escaping () -> SheetView) {
        self._isPresented = isPerented
        self.content = content
    }

    var body: some View {
        VStack {
            Spacer()
            content()
                .offset(y: isPresented ? 0 : UIScreen.main.bounds.height)
                .onTapGesture {}
        }
        .background(isPresented ? backgroundColor.opacity(0.5) : Color.clear)
        .onTapGesture {
            isPresented = false
        }
        .animation(.easeInOut(duration: 0.2))
    }
}

extension View {
    func addPartialSheet<SheetView: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> SheetView
    ) -> some View {
        ZStack {
            self
            PartialSheetView(
                isPerented: isPresented,
                content: content)
        }
    }
}
