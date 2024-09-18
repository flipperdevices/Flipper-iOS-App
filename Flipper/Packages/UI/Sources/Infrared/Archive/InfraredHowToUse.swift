import SwiftUI

struct InfraredHowToUseDialog: View {
    @Environment(\.colorScheme) private var colorScheme

    @Binding var isPresented: Bool
    let type: `Type`

    enum `Type` {
        case fff
        case library
    }

    private var descriptionColor: Color {
        switch colorScheme {
        case .light: .black40
        default: .black30
        }
    }

    private var image: String {
        switch type {
        case .fff: "InfraredHowToFFF"
        case .library: "InfraredHowToRemoteLibrary"
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            Image(image)
                .padding(.top, 16)

            VStack(spacing: 4) {
                Text("How to Use")
                    .font(.system(size: 14, weight: .bold))

                Text("Point Flipper Zero at the device. Tap or hold " +
                     "the button from your phone to send the signal remotely")
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(descriptionColor)
            }
            .padding(.horizontal, 12)

            Button {
                isPresented = false
            } label: {
                Text("Got It")
                    .frame(height: 41)
                    .frame(maxWidth: .infinity)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .background(Color.a2)
                    .cornerRadius(30)
            }
        }
    }
}
