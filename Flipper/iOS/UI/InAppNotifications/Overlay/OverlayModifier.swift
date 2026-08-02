import SwiftUI

struct OverlayModifier<OverlayContent: View>: ViewModifier {
    var isPresented: Binding<Bool>
    var interaction: OverlayInteraction
    @ViewBuilder var overlayContent: () -> OverlayContent

    @EnvironmentObject private var controller: OverlayController

    init(
        isPresented: Binding<Bool>,
        interaction: OverlayInteraction = .fullscreen,
        @ViewBuilder overlayContent: @escaping () -> OverlayContent
    ) {
        self.isPresented = isPresented
        self.interaction = interaction
        self.overlayContent = overlayContent
    }

    func body(content: Content) -> some View {
        content
            // NOTE: can't use controller.dismiss here as the isPresented
            // change doesn't fire when containing view was dismissed
            .onChange(of: isPresented.wrappedValue) { newValue in
                if newValue {
                    controller.present(
                        interaction: interaction,
                        content: overlayContent)
                }
            }
    }
}
