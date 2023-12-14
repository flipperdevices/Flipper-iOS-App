import SwiftUI

struct OverlayModifier<AlertContent: View>: ViewModifier {
    var isPresented: Binding<Bool>
    @ViewBuilder var alertContent: () -> AlertContent

    @EnvironmentObject private var controller: OverlayController

    init(
        isPresented: Binding<Bool>,
        @ViewBuilder alertContent: @escaping () -> AlertContent
    ) {
        self.isPresented = isPresented
        self.alertContent = alertContent
    }

    func body(content: Content) -> some View {
        content
            // NOTE: can't use controller.dismiss here as the isPresented
            // change doesn't fire when containing view was dismissed
            .onChange(of: isPresented.wrappedValue) { newValue in
                if newValue {
                    controller.present(content: alertContent)
                }
            }
    }
}
