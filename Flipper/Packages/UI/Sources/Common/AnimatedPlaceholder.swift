import SwiftUI

struct AnimatedPlaceholder: View {
    @State var startPoint: UnitPoint = .init(x: 0, y: 0)
    @State var endPoint: UnitPoint = .init(x: -10, y: 0)

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
            startPoint: startPoint,
            endPoint: endPoint
        )
        .cornerRadius(4)
        .task {
            withAnimation(animation) {
                startPoint = .init(x: 10, y: 0)
                endPoint = .init(x: 0, y: 0)
            }
        }
    }
}

struct AnimatedPlaceholderPreview: PreviewProvider {
    static var previews: some View {
        AnimatedPlaceholder()
            .frame(width: 50, height: 17)
            .padding(.horizontal, 50)
    }
}
