import SwiftUI

struct OverlayModifier<OverlayContent: View>: ViewModifier {
    var isPresented: Binding<Bool>
    @ViewBuilder var overlayContent: () -> OverlayContent

    @EnvironmentObject private var controller: OverlayController

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented.wrappedValue) { newValue in
                if newValue {
                    controller.present(content: overlayContent)
                } else {
                    controller.dismiss()
                }
            }
    }
}
