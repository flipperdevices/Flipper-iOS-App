import SwiftUI

struct HelpView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 8) {
                Spacer()
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.primary)
            }
            .padding([.top, .trailing], 18)

            Text("Can’t Find your Flipper?")
                .font(.system(size: 22, weight: .bold))
                .padding(.top, 16)
                .padding(.bottom, 20)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HelpPoint(
                        number: "1",
                        text: "Check the correct name of your Flipper",
                        linkLabel: "How to know the name of Flipper",
                        linkURL: .helpToKnowName)

                    HelpPoint(
                        number: "2",
                        text: "Make sure Bluetooth on your Flipper is turned On.",
                        linkLabel: "How to turn On Bluetooth on Flipper",
                        linkURL: .helpToTurnOnBluetooth)

                    HelpPoint(
                        number: "3",
                        text: "Check Bluetooth connection on your phone.",
                        linkLabel: "Go to Bluetooth settings",
                        linkURL: .systemSettings)

                    HelpPoint(
                        number: "4",
                        text: "Disconnect your Flipper from other apps and devices.",
                        linkLabel: nil,
                        linkURL: nil)

                    HelpPoint(
                        number: "5",
                        text: "Install the latest firmware version on Flipper. It’s important to update regularly.",
                        linkLabel: "Install here",
                        linkURL: .helpToInstallFirmware)

                    HelpPoint(
                        number: "6",
                        text: "Check that you have the latest version of the Flipper App installed.",
                        linkLabel: "Go to App Store",
                        linkURL: .appStore)

                    HelpPoint(
                        number: "7",
                        text: "Try to reboot your Flipper.",
                        linkLabel: "How to reboot Flipper",
                        linkURL: .helpToReboot)
                }
            }
            .padding(.leading, 14)
            .padding(.trailing, 12)

            Spacer()
        }
    }
}

struct HelpPoint: View {
    let number: String
    let text: String
    let linkLabel: String?
    let linkURL: URL?

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            VStack(alignment: .leading) {
                Text("\(number).")
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(text)
                if let linkLabel = linkLabel, let linkURL = linkURL {
                    Button {
                        UIApplication.shared.open(linkURL)
                    } label: {
                        Text(linkLabel)
                            .underline()
                    }
                }
            }
        }
        .font(.system(size: 16, weight: .medium))
    }
}
