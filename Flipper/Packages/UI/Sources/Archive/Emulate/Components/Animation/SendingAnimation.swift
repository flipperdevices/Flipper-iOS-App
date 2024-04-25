import SwiftUI

struct SendingAnimation: View {
    @State private var isAnimation: Bool = false

    private var blinkColor: Color {
        .init(.init(red: 0.54, green: 0.17, blue: 0.89, alpha: 1.0))
    }

    var body: some View {
        ZStack {
            Image("SendingStatic")
                .resizable()
            Image("SendingDynamic")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(isAnimation ? .white : blinkColor)
                .animation(
                    .easeInOut(duration: 0.1)
                    .repeatForever(autoreverses: true),
                    value: isAnimation
                )
        }
        .onAppear {
            isAnimation = true
        }
        .onDisappear {
            isAnimation = false
        }
    }
}
