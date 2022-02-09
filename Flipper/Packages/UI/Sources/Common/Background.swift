import SwiftUI

extension View {
    var systemBackground: Color {
        .init(UIColor.systemBackground)
    }
}

extension View {
    func customBackground(_ color: Color) -> some View {
        ZStack {
            color.edgesIgnoringSafeArea(.all)
            self
        }
    }
}
