import SwiftUI

struct NotificationView<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content

    @State private var isPresentedAnimated: Bool = false

    @EnvironmentObject var controller: OverlayController
    @Environment(\.updateOverlayInteraction)
    private var updateInteraction

    var animationDuration: Double { 0.1 }
    var presentingDuration: Double { 5.0 }

    var body: some View {
        ZStack(alignment: .bottom) {
            content
                // NOTE: collapses the Spacer inside Banner so the
                // measured frame is the visible banner, not the
                // whole screen
                .fixedSize(horizontal: false, vertical: true)
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                updateInteraction(
                                    .regions([proxy.frame(in: .global)]))
                            }
                            .onChange(of: proxy.frame(in: .global)) { frame in
                                updateInteraction(.regions([frame]))
                            }
                    }
                )
                .padding(.bottom, 50)
                .opacity(isPresentedAnimated ? 1 : 0)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .bottom
                )
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
        self.modifier(OverlayModifier(
            isPresented: isPresented,
            interaction: .regions([])
        ) {
            NotificationView(
                isPresented: isPresented,
                content: content())
        })
    }
}
