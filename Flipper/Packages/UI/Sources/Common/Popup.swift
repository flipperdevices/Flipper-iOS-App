import SwiftUI

extension View {
    func popup<Content: View>(
        isPresented: Binding<Bool>,
        hideOnTap: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        fullScreenCover(isPresented: isPresented) {
            ZStack(alignment: .top) {
                Color.black
                    .opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        if hideOnTap {
                            withoutAnimation {
                                isPresented.wrappedValue = false
                            }
                        }
                    }

                content()
            }
            .background(BackgroundCleaner())
        }
    }
}

func withoutAnimation(_ body: () -> Void) {
    var transaction = Transaction()
    transaction.disablesAnimations = true
    withTransaction(transaction) {
        body()
    }
}

struct BackgroundCleaner: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
