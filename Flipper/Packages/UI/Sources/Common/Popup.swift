import SwiftUI

extension View {
    func popup<Content: View>(
        isPresented: Binding<Bool>,
        hideOnTap: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        ZStack {
            self
            Popup(isPresented: isPresented, hideOnTap: hideOnTap, content: content)
        }
    }
}

struct Popup<Content: View>: View {
    @EnvironmentObject var alertController: AlertController

    @Binding var isPresented: Bool
    var hideOnTap: Bool
    @ViewBuilder var content: () -> Content

    var body: some View {
        EmptyView().onChange(of: isPresented) { newValue in
            if newValue {
                alertController.show {
                    ZStack(alignment: .top) {
                        Color.black
                            .opacity(0.3)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                if hideOnTap {
                                    isPresented = false
                                }
                            }

                        content()
                    }
                }
            } else {
                alertController.hide()
            }
        }
    }
}
