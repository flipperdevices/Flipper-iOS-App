import Core
import SwiftUI

extension AppView {
    struct AppStatusButton: View {
        let application: Applications.Application

        @State var isNotConnectedAlertPresented = false
        @State var isRebuildingAlertPresented = false
        @State var isOutdatedAppAlertPresented = false
        @State var isUnsupportedSDKAlertPresented = false
        @State var isOutdatedDeviceAlertPresented = false

        var body: some View {
            Button {
                switch application.current.status {
                case .ready: isNotConnectedAlertPresented = true
                case .building: isRebuildingAlertPresented = true
                case .unsupported: isOutdatedAppAlertPresented = true
                case .unsupportedSDK: isUnsupportedSDKAlertPresented = true
                case .outdatedDevice: isOutdatedAppAlertPresented = true

                }
            } label: {
                AppStatus(application: application)
            }
            .customAlert(isPresented: $isNotConnectedAlertPresented) {
                FlipperIsNotConnectedAlert(
                    isPresented: $isNotConnectedAlertPresented)
            }
        }
    }

    struct AppStatus: View {
        let application: Applications.Application

        var foregroundColor: Color {
            switch application.current.status {
            case .ready: return .init(red: 0.15, green: 0.55, blue: 0.26)
            case .building: return .init(red: 0.66, green: 0.56, blue: 0)
            default: return .init(red: 0.77, green: 0, blue: 0.28)
            }
        }

        var backgroundColor: Color {
            switch application.current.status {
            case .ready:
                return .init(red: 0.58, green: 0.98, blue: 0.69).opacity(0.15)
            case .building:
                return .init(red: 1, green: 0.89, blue: 0).opacity(0.2)
            default:
                return .init(red: 0.98, green: 0.58, blue: 0.62).opacity(0.2)
            }
        }

        var image: String {
            switch application.current.status {
            case .ready: return "AppStatusCheck"
            default: return "AppStatusWarning"
            }
        }

        var message: String {
            switch application.current.status {
            case .ready: return "Runs on latest firmware Release"
            case .building: return "App is rebuilding..."
            case .outdatedDevice: return "Update Flipper to latest Release"
            default: return "Outdated app"
            }
        }

        var body: some View {
            Group {
                HStack {
                    Image("AppStatusInfo")
                        .opacity(0)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(image)
                            .renderingMode(.template)

                        Text(message)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(foregroundColor)

                    Spacer()

                    Image("AppStatusInfo")
                }
                .padding(.horizontal, 12)
            }
            .frame(height: 32)
            .background(backgroundColor)
            .cornerRadius(8)
        }
    }
}
