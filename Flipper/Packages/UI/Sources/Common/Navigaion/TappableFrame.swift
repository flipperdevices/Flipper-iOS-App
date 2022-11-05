import SwiftUI

extension View {
    @inlinable
    func tappableFrame() -> some View {
        self
            .frame(minWidth: 44, minHeight: 44)
    }
}
