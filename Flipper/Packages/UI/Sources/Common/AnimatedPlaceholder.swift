import SwiftUI

struct AnimatedPlaceholder: View {
    @State private var isAnimating = false
    @State private var points: Points = .init(
        start: .init(x: 0, y: 0),
        end: .init(x: -10, y: 0)
    )

    struct Points: Equatable {
        var start: UnitPoint
        var end: UnitPoint
    }

    let color1: Color
    let color2: Color

    init(
        color1: Color = .init(red: 0.85, green: 0.85, blue: 0.85, opacity: 0.2),
        color2: Color = .init(red: 0.86, green: 0.86, blue: 0.86, opacity: 1)
    ) {
        self.color1 = color1
        self.color2 = color2
    }

    var animation: SwiftUI.Animation {
        .linear(duration: 2).repeatForever(autoreverses: true)
    }

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [color1, color2, color1]),
            startPoint: points.start,
            endPoint: points.end
        )
        .cornerRadius(4)
        .onAppear {
            isAnimating = true
        }
        .onDisappear {
            isAnimating = false
        }
        .animation(isAnimating ? animation : nil, value: points)
        .task {
            points = .init(
                start: .init(x: 10, y: 0),
                end: .init(x: 0, y: 0))
        }
    }
}

#Preview {
    AnimatedPlaceholder()
        .frame(width: 50, height: 17)
        .padding(.horizontal, 50)
}
