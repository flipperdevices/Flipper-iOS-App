import SwiftUI

struct EmulatingAnimation: View {
    @State private var isAnimation: Bool = false

    private var blinkColor: Color {
        .init(.init(red: 0.082, green: 0.67, blue: 1.0, alpha: 1.0))
    }

    var body: some View {
        ZStack {
            Image("EmulatingStatic")
                .resizable()
            Image("EmulatingDynamic")
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
