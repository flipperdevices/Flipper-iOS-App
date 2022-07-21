import SwiftUI

class HexKeyboardController: ObservableObject {
    @Published var isHidden = true

    var onKey: (Key) -> Void = { _ in }

    enum Key: Equatable {
        case ok
        case back
        case hex(String)
    }

    func show(onKey: @escaping (Key) -> Void) {
        self.onKey = onKey
        withAnimation {
            isHidden = false
        }
    }

    func hide() {
        withAnimation {
            isHidden = true
        }
    }
}
