import SwiftUI

struct OverlayModifier<AlertContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    @ViewBuilder var alertContent: () -> AlertContent

    @EnvironmentObject private var controller: OverlayController

    init(
        isPresented: Binding<Bool>,
        @ViewBuilder alertContent: @escaping () -> AlertContent
    ) {
        self._isPresented = isPresented
        self.alertContent = alertContent
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { newValue in
                newValue
                    ? controller.present(content: alertContent)
                    : controller.dismiss()
            }
    }
}
