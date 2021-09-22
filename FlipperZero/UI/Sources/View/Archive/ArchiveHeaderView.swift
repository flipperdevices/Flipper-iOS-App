import SwiftUI
import Core

struct ArchiveHeaderView: View {
    let device: Peripheral?
    var onOptions: () -> Void
    var onAddItem: () -> Void

    @Binding var isEditing: Bool

    init(
        device: Peripheral? = nil,
        isEditing: Binding<Bool>,
        onOptions: @escaping () -> Void = {},
        onAddItem: @escaping () -> Void = {}
    ) {
        self.device = device
        self._isEditing = isEditing
        self.onOptions = onOptions
        self.onAddItem = onAddItem
    }

    var body: some View {
        HStack {
            if isEditing {
                Button {
                    withAnimation {
                        isEditing = false
                    }
                } label: {
                    Text("Done")
                        .fontWeight(.medium)
                        .padding(.leading, 15.5)
                }
            } else {
                Button {
                    onOptions()
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .headerImageStyle()
                }
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
            .opacity(isEditing ? 0 : 1)
        }
        .frame(height: 44)
    }
}

struct HeaderDeviceView: View {
    let device: Peripheral?

    var name: String {
        device?.name ?? "No device"
    }

    var isConnected: Bool {
        device?.state == .connected
    }

    var activeColor: Color {
        .init(red: 0.2, green: 0.78, blue: 0.64)
    }
    var inactiveColor: Color {
        .init(red: 0.74, green: 0.76, blue: 0.78)
    }

    var strokeColor: Color {
        isConnected ? activeColor : inactiveColor
    }

    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "checkmark")
                .font(.system(size: 14))
                .foregroundColor(activeColor)
                .opacity(isConnected ? 1 : 0)
                .padding(.leading, 12)

            Text(name)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)

            if isConnected {
                Image("BluetoothOn")
                    .resizable()
                    .frame(width: 10, height: 14)
                    .padding(.trailing, 18)
            } else {
                Image("BluetoothOff")
                    .resizable()
                    .frame(width: 12, height: 14)
                    .padding(.trailing, 18)
            }
        }
        .frame(height: 30)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(strokeColor, lineWidth: 2)
        )
    }
}

extension Image {
    func headerImageStyle() -> some View {
        self.font(.system(size: 22))
            .padding(.horizontal, 15)
            .foregroundColor(Color.accentColor)
    }
}
