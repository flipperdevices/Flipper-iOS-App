import SwiftUI
import Core

struct ArchiveHeaderView: View {
    let device: Peripheral?
    var onOptions: () -> Void
    var onAddItem: () -> Void

    init(
        device: Peripheral? = nil,
        onOptions: @escaping () -> Void = {},
        onAddItem: @escaping () -> Void = {}
    ) {
        self.device = device
        self.onOptions = onOptions
        self.onAddItem = onAddItem
    }

    var body: some View {
        HStack {
            Button {
                onOptions()
            } label: {
                Image(systemName: "ellipsis.circle")
                    .headerImageStyle()
            }
            Spacer()
            HeaderDeviceView(device: device)
            Spacer()
            Button {
                onAddItem()
            } label: {
                Image(systemName: "plus.circle")
                    .headerImageStyle()
            }
        }
        .frame(height: 44)
    }
}

struct HeaderDeviceView: View {
    let device: Peripheral?

    var body: some View {
        // FIXME: replace images with code
        ZStack(alignment: .center) {
            Image(device?.state == .connected ? "CurrentDevice" : "CurrentNoDevice")
            Text(device?.name ?? "No device")
                .bold()
                .padding(.bottom, 5)
                .foregroundColor(Color.primary.opacity(device?.state == .connected ? 1 : 0.8))
        }
    }

}

extension Image {
    func headerImageStyle() -> some View {
        self.resizable()
            .frame(width: 22, height: 22)
            .scaledToFit()
            .padding(.horizontal, 15)
            .foregroundColor(Color.accentColor)
    }
}
