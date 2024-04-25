import SwiftUI

struct Spinner: View {
    var body: some View {
        LoadingAnimation()
            .frame(width: 24, height: 24)
    }
}

struct LoadingAnimation: View {
    private var duration: Double = 1.0
    private var degreesStep: Double = 25.0

    @State private var isAnimating = false
    @State private var rotationDegrees: Double = 0
    @State private var trimStart: CGFloat = 0
    @State private var trimEnd: CGFloat

    init() {
        trimEnd = degreesStep / 360
    }

    var body: some View {
        Circle()
             .trim(from: trimStart, to: trimEnd)
             .stroke(
                 Color.a2,
                 style: StrokeStyle(
                     lineWidth: 2.5,
                     lineCap: .round
                 )
             )
             .rotationEffect(.degrees(rotationDegrees - 90))
             .onAppear {
                 isAnimating = true
                 processAnimation()
             }
             .onDisappear {
                 isAnimating = false
            }
    }

    private func processAnimation() {
        Task {
            while isAnimating {
                withAnimation(
                    .linear(duration: duration)
                ) {
                    rotationDegrees = 180 + degreesStep
                    trimEnd = 1 - degreesStep / 360
                }
                try? await Task.sleep(seconds: duration)

                withAnimation(
                    .linear(duration: duration)
                ) {
                    rotationDegrees = 360 + degreesStep * 2
                    trimStart = 1 - (degreesStep * 2) / 360
                }
                try? await Task.sleep(seconds: duration)

                withAnimation(.linear(duration: 0)) {
                    rotationDegrees = 0
                    trimStart = 0
                    trimEnd = degreesStep / 360.0
                }
            }
        }
    }
}
