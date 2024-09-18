import SwiftUI

struct Spinner: View {
    var body: some View {
        LoadingAnimation()
            .frame(width: 24, height: 24)
    }
}

struct LoadingAnimation: View {
    @State private var degree = 90.0
    @State private var length = 0.95

    var rotateAnimation: Animation {
        .linear(duration: 1.0).repeatForever(autoreverses: false)
    }

    var lengthAnimagion: Animation {
        .easeIn(duration: 1.5).repeatForever(autoreverses: true)
    }

    var body: some View {
        Circle()
            .trim(from: 0.0, to: length)
            .stroke(
                Color.blue,
                style: StrokeStyle(
                    lineWidth: 2.5,
                    lineCap: .round
                )
            )
            .rotationEffect(.degrees(degree))
            .onAppear{
                withAnimation(rotateAnimation) {
                    degree += 360
                }
                withAnimation(lengthAnimagion) {
                    length = 0
                }
            }
            .onDisappear {
                degree = 90.0
                length = 0.95
            }
    }
}
