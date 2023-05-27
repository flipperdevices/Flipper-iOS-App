import SwiftUI

extension View {
    func hideScrollBackground() -> some View {
        if #available(iOS 16, *) {
            return self
                .scrollContentBackground(.hidden)
        } else {
            UITextView.appearance().backgroundColor = .clear
            return self
        }
    }
}
