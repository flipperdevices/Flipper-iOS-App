import Core
import SwiftUI

// swiftlint:disable function_default_parameter_at_end

struct HeaderView<LeftView: View, RightView: View>: View {
    let title: String
    let status: HeaderDeviceStatus
    let leftView: LeftView
    let rightView: RightView

    init(
        title: String? = nil,
        status: HeaderDeviceStatus,
        @ViewBuilder leftView: (() -> LeftView),
        @ViewBuilder rightView: (() -> RightView)
    ) {
        self.title = title ?? status.description
        self.status = status
        self.leftView = leftView()
        self.rightView = rightView()
    }

    var body: some View {
        HStack {
            leftView
                .frame(minWidth: 50)

            Spacer()

            HeaderDeviceView(name: title, status: status)

            Spacer()

            rightView
                .frame(minWidth: 50)
        }
        .frame(height: 44)
        .background(systemBackground)
    }
}

struct HeaderDeviceView: View {
    @State private var angle: Int = 0

    let name: String
    var status: HeaderDeviceStatus

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
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 94)

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
                    .opacity(status == .noDevice ? 0 : 1)
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

enum HeaderDeviceStatus: CustomStringConvertible {
    case connecting
    case connected
    case disconnected
    case noDevice

    var description: String {
        switch self {
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        case .disconnected: return "Disconnected"
        case .noDevice: return "No device"
        }
    }

    init(_ state: Peripheral.State?) {
        guard let state = state else {
            self = .noDevice
            return
        }
        switch state {
        case .connected: self = .connected
        case .connecting: self = .connecting
        case .disconnected: self = .disconnected
        case .disconnecting: self = .disconnected
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
