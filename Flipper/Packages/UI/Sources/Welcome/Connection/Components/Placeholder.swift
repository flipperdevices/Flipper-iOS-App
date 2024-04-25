import SwiftUI

struct ConnectPlaceholderView: View {
    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            HStack {
                Image("PhonePlaceholder")
                DotsAnimation()
                    .frame(width: 32, height: 32)
                    .padding(.horizontal, 8)
                Image("DevicePlaceholder")
            }
            .frame(width: 208)
            Text("Turn On Bluetooth on your Flipper")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black40)
            Spacer()
        }
    }
}

struct DotsAnimation: View {
    var body: some View {
        HStack(alignment: .center, spacing: 8.0) {
            DotAnimation(delay: 0)
            DotAnimation(delay: 0.25)
            DotAnimation(delay: 0.5)
        }
    }
}


struct DotAnimation: View {
    @State private var isAnimation: Bool = false
    let delay: Double

    var body: some View {
        Circle()
            .fill(Color.a2)
            .opacity(isAnimation ? 1.0 : 0.5)
            .animation(
                .easeInOut(duration: 0.5)
                .repeatForever(autoreverses: true),
                value: isAnimation
            )
            .onAppear {
                Task {
                    try await Task.sleep(seconds: delay)
                    isAnimation = true
                }
            }
            .onDisappear {
                isAnimation = false
            }
    }
}
