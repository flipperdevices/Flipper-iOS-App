import SwiftUI

struct NotificationView<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content

    @State private var isPresentedAnimated: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            content
                .padding(.bottom, 50)
                .opacity(isPresentedAnimated ? 1 : 0)
        }
        .onChange(of: isPresented) { newValue in
            guard !newValue else { return }
            withAnimation(.linear(duration: 0.1)) {
                isPresentedAnimated = false
            }
        }
        .task {
            withAnimation(.linear(duration: 0.1)) {
                isPresentedAnimated = true
            }
            try? await Task.sleep(seconds: 3)
            isPresented = false
        }
    }
}

extension View {
    @ViewBuilder
    func notification<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(OverlayModifier(isPresented: isPresented) {
            NotificationView(
                isPresented: isPresented,
                content: content())
        })
    }
}
