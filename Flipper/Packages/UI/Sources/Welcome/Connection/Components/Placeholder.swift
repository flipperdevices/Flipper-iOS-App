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
    @State var opacity = 0.5
    @State var isAnimated = false

    var animation: SwiftUI.Animation {
        .easeInOut(duration: 0.5)
        .repeatForever(autoreverses: true)
    }

    struct Dot: View {
        var body: some View {
            Circle()
                .fill(Color.blue)
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8.0) {
            Dot()
                .opacity(opacity)
                .animation(animation.delay(0.0), value: isAnimated)
            Dot()
                .opacity(opacity)
                .animation(animation.delay(0.25), value: isAnimated)
            Dot()
                .opacity(opacity)
                .animation(animation.delay(0.5), value: isAnimated)
        }
        .onAppear {
            withAnimation {
                opacity = 1.0
                isAnimated = true
            }
        }
        .onDisappear {
            isAnimated = false
        }
    }
}
