import SwiftUI

struct NotificationView<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content

    @State private var isPresentedAnimated: Bool = false

    @EnvironmentObject var controller: OverlayController

    var animationDuration: Double { 0.1 }
    var presentingDuration: Double { 5.0 }

    var body: some View {
        ZStack(alignment: .bottom) {
            content
                .padding(.bottom, 50)
                .opacity(isPresentedAnimated ? 1 : 0)
        }
        .onChange(of: isPresented) { newValue in
            guard !newValue else { return }
            hide()
        }
        .onAppear {
            show()
        }
    }

    func show() {
        Task {
            withAnimation(.linear(duration: animationDuration)) {
                isPresentedAnimated = true
            }
            try? await Task.sleep(seconds: presentingDuration)
            isPresented = false
        }
    }

    func hide() {
        Task {
            withAnimation(.linear(duration: animationDuration)) {
                isPresentedAnimated = false
            }
            try? await Task.sleep(seconds: animationDuration)
            controller.dismiss()
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
