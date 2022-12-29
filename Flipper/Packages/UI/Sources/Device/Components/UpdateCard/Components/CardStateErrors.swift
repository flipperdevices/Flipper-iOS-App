import Core
import SwiftUI

extension DeviceUpdateCard {
    struct CardNoSDError: View {
        @EnvironmentObject var flipperService: FlipperService
        @EnvironmentObject var checkUpdateService: CheckUpdateService

        var body: some View {
            VStack(spacing: 2) {
                Image("NoSDCard")
                Text("No SD сard")
                    .font(.system(size: 14, weight: .medium))
                HStack {
                    Text("Install SD card in Flipper to update firmware")
                        .font(.system(size: 14, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black30)
                }
                .padding(.horizontal, 12)
            }
            .padding(.vertical, 4)

            Button {
                updateStorageInfo()
            } label: {
                Text("Retry")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.a2)
            }
            .padding(.bottom, 8)
        }

        func updateStorageInfo() {
            Task {
                try? await flipperService.updateStorageInfo()
            }
        }
    }

    struct CardNoInternetError: View {
        @EnvironmentObject var checkUpdateService: CheckUpdateService

        var body: some View {
            VStack(spacing: 2) {
                Image("NoInternet")
                Text("No Internet connection")
                    .font(.system(size: 14, weight: .medium))
                HStack {
                    Text("Can’t connect to update server")
                        .font(.system(size: 14, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black30)
                }
                .padding(.horizontal, 12)
            }
            .padding(.vertical, 4)

            Button {
                checkUpdateService.updateAvailableFirmware()
            } label: {
                Text("Retry")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.a2)
            }
            .padding(.bottom, 8)
        }
    }

    struct CardCantConnectError: View {
        @EnvironmentObject var checkUpdateService: CheckUpdateService

        var body: some View {
            VStack(spacing: 2) {
                Image("ServerError")
                Text("Unable to download firmware")
                    .font(.system(size: 14, weight: .medium))
                HStack {
                    Text("Can’t connect to update server")
                        .font(.system(size: 14, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black30)
                }
                .padding(.horizontal, 12)
            }
            .padding(.vertical, 4)

            Button {
                checkUpdateService.updateAvailableFirmware()
            } label: {
                Text("Retry")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.a2)
            }
            .padding(.bottom, 8)
        }
    }

    struct CardNoDeviceError: View {
        var body: some View {
            VStack(spacing: 2) {
                Image("UpdateNoDevice")
                Text("Connect to Flipper to see available updates")
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black30)
                    .padding(.horizontal, 12)
            }
            .padding(.top, 26)
            .padding(.bottom, 26)
        }
    }
}
