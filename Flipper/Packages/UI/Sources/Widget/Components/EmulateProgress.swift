import SwiftUI

struct EmulateProgress: View {
    @State private var rotation = 0.0

    var animation: SwiftUI.Animation {
        .linear(duration: 1).repeatForever(autoreverses: false)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.a2.opacity(0.3), lineWidth: 2)
                .frame(width: 20, height: 20)

            Circle()
                .trim(from: 0, to: 0.25)
                .stroke(Color.a2, lineWidth: 2)
                .frame(width: 20, height: 20)
                .rotationEffect(.degrees(rotation))

            RoundedRectangle(cornerRadius: 1)
                .fill(Color.a2)
                .frame(width: 5.71, height: 5.71)
        }
        .task {
            withAnimation(animation) {
                rotation = 360
            }
        }
    }
}
