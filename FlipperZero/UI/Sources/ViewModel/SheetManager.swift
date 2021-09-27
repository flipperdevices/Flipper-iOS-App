import Combine
import SwiftUI

class SheetManager: ObservableObject {
    static let shared: SheetManager = .init()

    @Published var offset = UIScreen.main.bounds.height
    @Published var isPresented = false {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.offset = self.isPresented ? 0 : UIScreen.main.bounds.height
            }
        }
    }
    var content: AnyView?

    func present<Content: View>(content: () -> Content) {
        self.content = AnyView(content())
        self.isPresented = true
    }
}
