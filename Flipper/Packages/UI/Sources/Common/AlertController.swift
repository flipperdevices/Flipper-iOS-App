import SwiftUI

class AlertController: ObservableObject {
    static let shared: AlertController = .init()

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
