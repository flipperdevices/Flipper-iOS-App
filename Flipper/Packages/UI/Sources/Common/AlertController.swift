import SwiftUI

class AlertController: ObservableObject {
    @Published var isPresented = false
    var alert = AnyView(EmptyView())

    func show<Content: View>(@ViewBuilder content: () -> Content) {
        alert = AnyView(content())
        isPresented = true
    }

    func hide() {
        isPresented = false
        alert = AnyView(EmptyView())
    }
}
