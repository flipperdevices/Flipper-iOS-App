import Analytics
import SwiftUI

let analytics: Analytics = Analytics()

extension View {
    func analyzingTapGesture(_ action: @escaping () -> Void) -> some View {
        simultaneousGesture(TapGesture().onEnded {
            action()
        })
    }
}
