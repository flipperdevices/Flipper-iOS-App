import SwiftUI

extension View {
    func popup<Content: View>(
        isPresented: Binding<Bool>,
        hideOnTap: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.onChange(of: isPresented.wrappedValue) { newValue in
            if newValue {
                AlertController.shared.show {
                    ZStack(alignment: .top) {
                        Color.black
                            .opacity(0.3)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                if hideOnTap {
                                    isPresented.wrappedValue = false
                                }
                            }

                        content()
                    }
                }
            } else {
                AlertController.shared.hide()
            }
        }
    }
}
