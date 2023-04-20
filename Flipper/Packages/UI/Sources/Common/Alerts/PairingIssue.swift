import SwiftUI

struct PairingIssueAlert: View {
    var isPresented: Binding<Bool>

    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 0) {
            Text("Can’t connect to Flipper")
                .font(.system(size: 16, weight: .bold))
            Text(
                "Bluetooth pairing failed. " +
                "Remove old pairing from iPhone Settings."
            )
            .font(.system(size: 14, weight: .medium))
            .multilineTextAlignment(.center)
            .foregroundColor(.black40)
            .padding(.horizontal, 12)
            .padding(.top, 6)

            VStack(spacing: 24) {
                VStack(spacing: 4) {
                    HStack {
                        Text("1.")
                            .font(.system(size: 14, weight: .bold))
                        Text("Go to iPhone Bluetooth Settings")
                            .font(.system(size: 14, weight: .regular))
                        Spacer()
                    }
                    HStack(alignment: .center, spacing: 4) {
                        Image("PairingIssue1_1")
                            .resizable()
                            .frame(width: 40, height: 40)
                        Image("PairingIssue1_2")
                            .resizable()
                            .frame(width: 204, height: 36)
                    }
                    .padding(.horizontal, 10)
                }

                VStack(spacing: 4) {
                    HStack {
                        Text("2.")
                            .font(.system(size: 14, weight: .bold))
                        Text("Choose your Flipper")
                            .font(.system(size: 14, weight: .regular))
                        Spacer()
                    }
                    HStack(alignment: .center, spacing: 4) {
                        Image("PairingIssue2")
                            .resizable()
                            .frame(width: 248, height: 33)
                    }
                    .padding(.horizontal, 10)
                }

                VStack(spacing: 4) {
                    HStack {
                        Text("3.")
                            .font(.system(size: 14, weight: .bold))
                        Text("Press “Forget This Device” button")
                            .font(.system(size: 14, weight: .regular))
                        Spacer()
                    }
                    HStack(alignment: .center, spacing: 4) {
                        Image("PairingIssue3")
                            .resizable()
                            .frame(width: 248, height: 77)
                    }
                    .padding(.horizontal, 10)
                }

                Button {
                    openURL(.systemSettings)
                    isPresented.wrappedValue = false
                } label: {
                    Text("Go to Settings")
                        .roundedButtonStyle(maxWidth: .infinity)
                }
            }
            .padding(.top, 30)
            .padding(.bottom, 12)
            .padding(.horizontal, 12)
        }
        .frame(width: 292)
        .padding(.top, 9)
        .background(RoundedRectangle(cornerRadius: 18)
            .fill(Color.secondaryGroupedBackground)
        )
    }
}
