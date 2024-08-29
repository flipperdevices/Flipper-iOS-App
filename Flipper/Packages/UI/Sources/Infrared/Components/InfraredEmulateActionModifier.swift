import Core
import SwiftUI

private struct EmulateActionModifier: ViewModifier {
    @EnvironmentObject private var emulate: Emulate
    @Environment(\.emulateAction) private var action

    @State private var isPressed = false
    let keyID: InfraredKeyID

    private func onStart() {
        action(keyID)
    }

    private func onStop() {
        emulate.stopEmulate()
    }

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !isPressed else { return }
                        isPressed = true
                        onStart()
                    }
                    .onEnded { _ in
                        isPressed = false
                        onStop()
                    }
            )
    }
}

extension View {
    func onEmulate(keyID: InfraredKeyID) -> some View {
        self.modifier(EmulateActionModifier(keyID: keyID))
    }
}
