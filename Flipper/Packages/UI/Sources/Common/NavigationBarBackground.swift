import SwiftUI

extension View {
    func navigationBarBackground<S: ShapeStyle>(_ style: S) -> some View {
        self
            .toolbarBackground(style, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}
