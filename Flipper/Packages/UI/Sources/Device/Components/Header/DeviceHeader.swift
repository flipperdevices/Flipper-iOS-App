import Core
import SwiftUI

struct DeviceHeader: View {
    var device: Flipper?

    var body: some View {
        VStack {
            if let device = device {
                DeviceInfoHeader(flipper: device)
                    .padding(.top, 4)
                    .padding(.bottom, 12)
                    .padding(.horizontal, 14)
            } else {
                NoDeviceHeader(flipper: device)
                    .padding(.top, 4)
                    .padding(.bottom, 12)
                    .padding(.horizontal, 14)
            }
        }
        .frame(height: 116)
        .frame(maxWidth: .infinity)
        .background(Color.a1)
    }
}

struct NoDeviceHeader: View {
    let flipper: Flipper?

    var body: some View {
        HStack(spacing: 18) {
            FlipperDeviceImage()
                .flipperColor(flipper?.color)
                .flipperState(.dead)

            VStack(alignment: .center, spacing: 6) {
                Text("No Device")
                    .font(.system(size: 16, weight: .bold))
            }
        }
    }
}

struct DeviceInfoHeader: View {
    let flipper: Flipper

    var batteryColor: Color {
        guard let battery = flipper.battery else {
            return .clear
        }
        switch Int(battery.decimalValue * 100) {
        case ...15: return .sRed
        case 16...40: return .sYellow
        case 41...: return .sGreen
        default: return .clear
        }
    }

    var body: some View {
        HStack(spacing: 18) {
            FlipperDeviceImage()
                .flipperColor(flipper.color)
                .flipperState(flipper.state == .connected ? .normal : .dead)

            VStack(alignment: .center, spacing: 6) {
                Text(flipper.name)
                    .font(.system(size: 16, weight: .bold))

                Text("Flipper Zero")
                    .font(.system(size: 12, weight: .medium))

                HStack(alignment: .top, spacing: 5.5) {
                    if let battery = flipper.battery {
                        ZStack(alignment: .topLeading) {
                            Image("Battery")

                            RoundedRectangle(cornerRadius: 1)
                                .frame(
                                    width: 23.96 * battery.decimalValue,
                                    height: 8.87)
                                .padding(.top, 2.53)
                                .padding(.leading, 2.66)
                                .foregroundColor(batteryColor)

                            Image("Charging")
                                .offset(x: 6, y: -2)
                                .opacity(battery.state == .charging ? 1 : 0)
                        }

                        Text("\(battery.level)%")
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                .frame(height: 9)
                .opacity(flipper.battery == nil ? 0 : 1)
                .opacity(flipper.state == .disconnected ? 0 : 1)
                .padding(.top, 3)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
