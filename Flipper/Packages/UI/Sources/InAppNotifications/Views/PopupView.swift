import SwiftUI

struct PopupView<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content

    @State private var isPresentedAnimated: Bool = false

    @EnvironmentObject var controller: OverlayController

    var animationDuration: Double { 0.1 }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    guard isPresented else { return }
                    isPresented = false

                    hide()
                }
                .opacity(isPresentedAnimated ? 1 : 0)

            content
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
        withAnimation(.linear(duration: animationDuration)) {
            isPresentedAnimated = true
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
