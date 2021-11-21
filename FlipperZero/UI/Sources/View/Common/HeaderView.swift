import Core
import SwiftUI

// swiftlint:disable function_default_parameter_at_end

struct HeaderView<LeftView: View, RightView: View>: View {
    let title: String
    let status: Status
    let leftView: LeftView
    let rightView: RightView

    init(
        title: String? = nil,
        status: Status,
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
    @StateObject var animation: RotationAnimation = .init()

    let name: String
    var status: Status

    var isConnecting: Bool {
        status == .connecting
    }

    var isConnected: Bool {
        status == .connected
    }

    var isSynchronizing: Bool {
        status == .synchronizing
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
        case .connecting, .synchronizing: return arrowsColor
        default: return .clear
        }
    }

    var strokeColor: Color {
        (isConnected || isSynchronizing) ? activeColor : inactiveColor
    }

    var body: some View {
        HStack(alignment: .center) {
            ZStack {
                if isConnecting || isSynchronizing {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 14))
                        .frame(width: 14, height: 14, alignment: .center)
                        .foregroundColor(arrowsColor)
                        .rotationEffect(.degrees(Double(-animation.angle)))
                        .onAppear { animation.start() }
                        .onDisappear { animation.stop() }
                } else {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14))
                        .frame(width: 14, height: 14, alignment: .center)
                        .foregroundColor(activeColor)
                }
            }
            .padding(.leading, 12)

            Text(name)
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 94)

            if isConnected || isConnecting || isSynchronizing {
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
                    angle: .degrees(Double(-animation.angle))
                ),
                lineWidth: 2)
    }

    var staticBorder: some View {
        RoundedRectangle(cornerRadius: 15)
            .stroke(strokeColor, lineWidth: 2)
    }
}

class RotationAnimation: ObservableObject {
    @Published var angle: Int = 0
    var isAnimating = false

    init() {}

    func start() {
        isAnimating = true
        animate()
    }

    func animate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.angle == 0 {
                self.angle = 360
            }
            withAnimation {
                self.angle -= 45
            }
            if self.isAnimating {
                self.animate()
            }
        }
    }

    func stop() {
        isAnimating = false
    }
}

extension Image {
    func headerImageStyle() -> some View {
        self.font(.system(size: 22))
            .padding(.horizontal, 15)
            .foregroundColor(Color.accentColor)
    }
}
