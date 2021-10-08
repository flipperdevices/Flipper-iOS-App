import SwiftUI
import Core

struct ArchiveHeaderView: View {
    @StateObject var viewModel: ArchiveViewModel

    var body: some View {
        HStack {
            if viewModel.isSelectItemsMode {
                Button {
                    withAnimation {
                        viewModel.isSelectItemsMode = false
                    }
                } label: {
                    Text("Done")
                        .fontWeight(.medium)
                        .padding(.leading, UIDevice.isFaceIDAvailable ? 15.5 : 14)
                }
            } else {
                Menu {
                    Button {
                        viewModel.toggleSelectItems()
                    } label: {
                        Text("Choose items")
                        Image(systemName: "checkmark.circle")
                    }
                    Menu {
                        Button("Creation Date") {
                            viewModel.sortItems(by: .creationDate)
                        }
                        Button("Title") {
                            viewModel.sortItems(by: .title)
                        }
                        Divider()
                            .frame(height: 10)
                        Button("Older First") {
                            viewModel.sortItems(by: .oldestFirst)
                        }
                        Button("Newest First") {
                            viewModel.sortItems(by: .newestFirst)
                        }
                    } label: {
                        Text("Sort items")
                        Image(systemName: "arrow.up.arrow.down.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .headerImageStyle()
                }
            }
            Spacer()

            HeaderDeviceView(
                name: viewModel.device?.name ?? "No device",
                status: viewModel.device?.state ?? .disconnected)

            Spacer()
            Button {
                viewModel.readNFCTag()
            } label: {
                Image(systemName: "plus.circle")
                    .headerImageStyle()
            }
            .opacity(viewModel.isSelectItemsMode ? 0 : 1)
        }
        .frame(height: 44)
    }
}

struct HeaderDeviceView: View {
    @State private var angle: Int = 0

    let name: String
    var status: Peripheral.State

    var isConnecting: Bool {
        status == .connecting
    }

    var isConnected: Bool {
        status == .connected
    }

    var activeColor: Color {
        .init(red: 0.23, green: 0.87, blue: 0.72)
    }
    var inactiveColor: Color {
        .clear
    }
    var arrowsColor: Color {
        .init(red: 0.99, green: 0.68, blue: 0.22)
    }

    var leftImageColor: Color {
        switch status {
        case .connected: return activeColor
        case .connecting: return arrowsColor
        default: return .clear
        }
    }

    var strokeColor: Color {
        isConnected ? activeColor : inactiveColor
    }

    var body: some View {
        HStack(alignment: .center) {
            // swiftlint:disable indentation_width
            Image(systemName: isConnecting
                  ? "arrow.triangle.2.circlepath"
                  : "checkmark")
                .font(.system(size: 14))
                .frame(width: 14, height: 14, alignment: .center)
                .foregroundColor(leftImageColor)
                .rotationEffect(.degrees(Double(isConnecting ? -angle : 0)))
                .padding(.leading, 12)

            Text(name)
                .fontWeight(.semibold)
                .padding(.horizontal, 16)

            if isConnected || isConnecting {
                Image("BluetoothOn")
                    .resizable()
                    .frame(width: 10, height: 14)
                    .padding(.trailing, 16)
            } else {
                Image("BluetoothOff")
                    .resizable()
                    .frame(width: 12, height: 14)
                    .padding(.trailing, 14)
            }
        }
        .frame(height: 30)
        .overlay(border)
    }

    var border: AnyView {
        isConnecting
            ? .init(animatedBorder)
            : .init(staticBorder)
    }

    var animatedBorder: some View {
        RoundedRectangle(cornerRadius: 15)
            .stroke(
                AngularGradient(
                    colors: [inactiveColor, activeColor],
                    center: .center,
                    angle: .degrees(Double(-angle))
                ),
                lineWidth: 2)
                    .onAppear {
                        if isConnecting {
                            startAnimation()
                        }
                    }
    }

    var staticBorder: some View {
        RoundedRectangle(cornerRadius: 15)
            .stroke(strokeColor, lineWidth: 2)
    }

    func startAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
            if angle == 0 {
                angle = 360
            }
            angle -= 1
            if isConnecting {
                startAnimation()
            }
        }
    }
}

extension Image {
    func headerImageStyle() -> some View {
        self.font(.system(size: 22))
            .padding(.horizontal, 15)
            .foregroundColor(Color.accentColor)
    }
}
