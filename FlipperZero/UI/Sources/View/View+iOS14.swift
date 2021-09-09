import SwiftUI

extension View {
    func iOS14<T: View>(@ViewBuilder modifier: (Self) -> T) -> some View {
        if ProcessInfo.processInfo.operatingSystemVersion.majorVersion == 14 {
            return AnyView(modifier(self))
        }
        return AnyView(self)
    }
}
