import SwiftUI

struct SendProgress: View {
    @State private var trimTo = 0.0

    var animation: SwiftUI.Animation {
        .linear(duration: 1).repeatForever(autoreverses: false)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.a1.opacity(0.3), lineWidth: 2)
                .frame(width: 20, height: 20)

            Circle()
                .trim(from: 0, to: trimTo)
                .stroke(Color.a1, lineWidth: 2)
                .frame(width: 20, height: 20)
                .rotationEffect(.degrees(-90))

            RoundedRectangle(cornerRadius: 1)
                .fill(Color.a1)
                .frame(width: 5.71, height: 5.71)
        }
        .task {
            withAnimation(animation) {
                trimTo = 1
            }
        }
    }
}
