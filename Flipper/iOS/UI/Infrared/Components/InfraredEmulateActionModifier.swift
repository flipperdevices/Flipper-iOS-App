import Core
import SwiftUI

private struct EmulateActionModifier: ViewModifier {
    @Environment(\.emulateItem) private var item: ArchiveItem?
    @Environment(\.layoutScaleFactor) private var layoutScale: Double

    @EnvironmentObject private var emulate: Emulate
    @EnvironmentObject private var device: Device

    @State private var isPressed = false
    let keyID: InfraredKeyID

    private var index: Int? {
        guard let item = item else { return nil }

        return item.properties.isEmpty // Brute force signals without content
            ? 0
            : item.infraredSignals.firstIndex(keyId: keyID)
    }

    func onTap() {
        guard
            let index = index, let item = item,
            let flipper = device.flipper
        else { return }

        if flipper.hasSingleEmulateSupport {
            emulate.emulateSingle(item, index: index)
        } else {
            emulate.startEmulate(item, .infrared(index: index))
            emulate.stopEmulate()
        }
    }

    func onPress() {
        guard
            let index = index, let item = item
        else { return }

        emulate.startEmulate(item, .infrared(index: index))
    }

    func onRelease() {
        emulate.stopEmulate()
    }

    func body(content: Content) -> some View {
        content
            .padding(16 * layoutScale) // Padding for more tapping zone
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
            .gesture(
                LongPressGesture(minimumDuration: 0.3)
                    .onEnded { _ in
                        onPress()
                    }.sequenced(before: DragGesture(minimumDistance: 0)
                        .onEnded { _ in
                            onRelease()
                        }
                    )
            )
    }
}

extension View {
    func emulatable(keyID: InfraredKeyID) -> some View {
        self.modifier(EmulateActionModifier(keyID: keyID))
    }
}
