import SwiftUI

struct OverlayModifier<OverlayContent: View>: ViewModifier {
    var isPresented: Binding<Bool>
    @ViewBuilder var overlayContent: () -> OverlayContent

    @EnvironmentObject private var controller: OverlayController

    init(
        isPresented: Binding<Bool>,
        @ViewBuilder overlayContent: @escaping () -> OverlayContent
    ) {
        self.isPresented = isPresented
        self.overlayContent = overlayContent
    }

    func body(content: Content) -> some View {
        content
            // NOTE: can't use controller.dismiss here as the isPresented
            // change doesn't fire when containing view was dismissed
            .onChange(of: isPresented.wrappedValue) { newValue in
                if newValue {
                    controller.present(content: overlayContent)
                }
            }
    }
}
