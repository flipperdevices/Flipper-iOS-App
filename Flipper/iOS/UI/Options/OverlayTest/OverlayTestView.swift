import SwiftUI

struct OverlayTestView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var showAlert = false
    @State private var showNotification = false
    @State private var showPopup = false

    @State private var tapCount = 0

    var body: some View {
        List {
            Section {
                Button {
                    tapCount += 1
                } label: {
                    HStack {
                        Text("Tap Counter")
                        Spacer()
                        Text("\(tapCount)")
                            .foregroundColor(.black40)
                    }
                }
            } header: {
                Text("Passthrough Check")
            } footer: {
                Text(
                    "While the notification banner is visible this " +
                    "button must stay tappable, but taps on the banner " +
                    "itself must not reach the screen behind it. " +
                    "While the alert or popup is visible the whole " +
                    "screen must be blocked."
                )
            }

            Section(header: Text("Overlays")) {
                Button("Show Alert") {
                    showAlert = true
                }
                Button("Show Notification") {
                    showNotification = true
                }
                Button("Show Popup") {
                    showPopup = true
                }
                Button("Show Notification, then Alert") {
                    showNotification = true
                    showAlert = true
                }
            }
        }
        .navigationBarBackground(Color.a1)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
            }
            PrincipalToolbarItems(alignment: .leading) {
                Title("Overlay Test")
            }
        }
        .alert(isPresented: $showAlert) {
            OverlayTestAlert(isPresented: $showAlert)
        }
        .notification(isPresented: $showNotification) {
            Banner(
                image: "Done",
                title: "Test Notification",
                description: "Taps around me should pass through"
            )
        }
        .popup(isPresented: $showPopup) {
            OverlayTestPopup()
                .frame(maxWidth: .infinity)
                .padding(.top, 120)
        }
    }
}

extension OverlayTestView {
    struct OverlayTestAlert: View {
        @Binding var isPresented: Bool

        var body: some View {
            VStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("Test Alert")
                        .font(.system(size: 14, weight: .bold))

                    Text(
                        "Taps on the dimmed background must not " +
                        "reach the screen behind this alert."
                    )
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black40)
                    .padding(.horizontal, 12)
                }
                .padding(.top, 25)

                AlertButtons(
                    isPresented: $isPresented,
                    text: "Got It",
                    cancel: "Cancel"
                ) {
                }
            }
        }
    }

    struct OverlayTestPopup: View {
        var body: some View {
            HStack {
                Spacer()
                Card {
                    VStack(spacing: 4) {
                        Text("Test Popup")
                            .font(.system(size: 14, weight: .bold))

                        Text("Tap outside to dismiss")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.black40)
                    }
                    .padding(12)
                }
                Spacer()
            }
        }
    }
}
