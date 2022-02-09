import SwiftUI

struct InstructionView: View {
    @StateObject var viewModel: InstructionViewModel
    @Environment(\.colorScheme) var colorScheme

    var backgroundColor: Color {
        colorScheme == .dark ? .backgroundDark : .backgroundLight
    }

    var body: some View {
        VStack {
            Text(
                """
                Turn On Bluetooth on
                your Flipper
                """)
                .font(.system(size: 24, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.top, 48)

            Image("BluetoothSettings")
                .resizable()
                .scaledToFit()
                .padding(.top, 48)

            Image("Breadcrumbs")
                .padding(.top, 8)

            Spacer()

            NavigationLink {
                ConnectionView(viewModel: .init())
                    .customBackground(backgroundColor)
            } label: {
                Text("Connect")
                    .frame(height: 51)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .font(.system(size: 16, weight: .bold))
                    .cornerRadius(25.5)
                    .padding(.horizontal, 18)
            }

            VStack(spacing: 8) {
                Text("By pressing Connect, you agree with our")
                    .foregroundColor(.black30)

                HStack {
                    Button {
                        viewModel.openTermsOfService()
                    } label: {
                        Text("Terms of Service")
                            .underline()
                    }

                    Text("and")
                        .foregroundColor(.black30)

                    Button {
                        viewModel.openPrivacyPolicy()
                    } label: {
                        Text("Privacy Policy")
                            .underline()
                    }
                }
                .font(.system(size: 16, weight: .medium))
            }
            .padding(.top, 18)
            .padding(.bottom, 12)
        }
        .navigationBarHidden(true)
        .navigationTitle("")
    }
}
