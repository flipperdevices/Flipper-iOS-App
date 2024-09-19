import SwiftUI

struct AlertView<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content

    @State private var isPresentedAnimated: Bool = false
    var animationDuration: Double { 0.1 }

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .opacity(isPresentedAnimated ? 1 : 0)

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.primary)
                }
                .padding(.top, 19)
                .padding(.trailing, 19)

                content
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
            }
            .frame(width: 292)
            .background(RoundedRectangle(cornerRadius: 18)
                .fill(.alertBackground)
            )
            .scaleEffect(isPresentedAnimated ? 1 : 1.1)
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
        }
    }
}

extension View {
    @ViewBuilder
    func alert<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(OverlayModifier(isPresented: isPresented) {
            AlertView(
                isPresented: isPresented,
                content: content())
        })
    }
}

extension ShapeStyle where Self == Color {
    static var alertBackground: Color {
        .init("AlertBackground")
    }
}
