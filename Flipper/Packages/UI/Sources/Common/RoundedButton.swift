import SwiftUI

extension View {
    func roundedButtonStyle(
        height: CGFloat? = 41,
        horizontalPadding: CGFloat? = 38,
        maxWidth: CGFloat? = nil,
        isDanger: Bool = false
    ) -> some View {
        self
            .frame(height: height)
            .frame(maxWidth: maxWidth)
            .padding(.horizontal, horizontalPadding)
            .font(.system(size: 14, weight: .bold))
            .background(isDanger ? Color.sRed : .a2)
            .cornerRadius(30)
            .foregroundColor(.white)
    }
}
