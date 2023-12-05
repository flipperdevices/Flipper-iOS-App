import SwiftUI

struct PopupView<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content

    @State private var isPresentedAnimated: Bool = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
                .opacity(isPresentedAnimated ? 1 : 0)

            content
                .opacity(isPresentedAnimated ? 1 : 0)
        }
        .onChange(of: isPresented) { newValue in
            guard !newValue else { return }
            withAnimation(.linear(duration: 0.1)) {
                isPresentedAnimated = false
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 0.1)) {
                isPresentedAnimated = true
            }
        }
    }
}

extension View {
    @ViewBuilder
    func popup<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(OverlayModifier(isPresented: isPresented) {
            PopupView(
                isPresented: isPresented,
                content: content())
        })
    }
}
