import Core
import SwiftUI

extension AppView {
    struct AppStatusButton: View {
        let application: Applications.Application

        var status: Applications.Application.Status {
            application.current.status
        }

        @State var isRunsOnReleasePresented = false
        @State var isRebuildingAlertPresented = false
        @State var isOutdatedAppAlertPresented = false
        @State var isOutdatedDeviceAlertPresented = false

        var body: some View {
            Button {
                switch status {
                case .ready: isRunsOnReleasePresented = true
                case .building: isRebuildingAlertPresented = true
                case .unsupported: isOutdatedAppAlertPresented = true
                case .unsupportedSDK: isOutdatedDeviceAlertPresented = true
                case .outdatedDevice: isOutdatedDeviceAlertPresented = true
                }
            } label: {
                AppStatus(status: status)
            }
            .customAlert(isPresented: $isRunsOnReleasePresented) {
                RunsOnLatestFirmwareAlert(
                    isPresented: $isRunsOnReleasePresented)
            }
            .customAlert(isPresented: $isRebuildingAlertPresented) {
                AppIsRebuildingAlert(
                    isPresented: $isRebuildingAlertPresented,
                    application: application)
            }
            .customAlert(isPresented: $isOutdatedAppAlertPresented) {
                AppsOutdatedAppAlert(
                    isPresented: $isOutdatedAppAlertPresented,
                    application: application)
            }
            .customAlert(isPresented: $isOutdatedDeviceAlertPresented) {
                AppsOutdatedFlipperAlert(
                    isPresented: $isOutdatedDeviceAlertPresented)
            }
        }
    }

    struct AppStatus: View {
        let status: Applications.Application.Status

        var foregroundColor: Color {
            switch status {
            case .ready: return .init("AppStatusGreenForeground")
            case .building: return .init("AppStatusYellowForeground")
            default: return .init("AppStatusRedForeground")
            }
        }

        var backgroundColor: Color {
            switch status {
            case .ready: return .init("AppStatusGreenBackground")
            case .building: return .init("AppStatusYellowBackground")
            default: return .init("AppStatusRedBackground")
            }
        }

        var image: String? {
            switch status {
            case .ready: return "AppStatusCheck"
            case .building, .unsupported: return "AppStatusWarning"
            case .outdatedDevice, .unsupportedSDK: return nil
            }
        }

        var message: String {
            switch status {
            case .ready:
                return "Runs on latest firmware Release"
            case .building:
                return "App is rebuilding..."
            case .unsupported:
                return "Outdated app"
            case .outdatedDevice, .unsupportedSDK:
                return "To install, update firmware from Release Channel"
            }
        }

        var body: some View {
            Group {
                HStack {
                    Image("AppStatusInfo")
                        .opacity(0)

                    Spacer()

                    HStack(spacing: 4) {
                        if let image = image {
                            Image(image)
                                .renderingMode(.template)
                        }

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
