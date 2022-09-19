import SwiftUI

struct Bubble: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing, spacing: 0) {
                Text(text)
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color.black20)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                RoundedTriangle(cornerRadius: 3)
                    .fill(Color.black20)
                    .frame(width: 15, height: 14)
                    .offset(x: -16)
            }
        }
    }

    struct RoundedTriangle: Shape {
        let cornerRadius: Double

        func path(in rect: CGRect) -> Path {
            Path { path in
                path.move(to: .init(x: rect.minX, y: rect.minY))

                path.addArc(
                    tangent1End: .init(x: rect.midX, y: rect.maxY),
                    tangent2End: .init(x: rect.maxX, y: rect.minY),
                    radius: cornerRadius)

                path.addLine(to: .init(x: rect.midX, y: rect.maxY))

                path.addLine(to: .init(x: rect.maxX, y: rect.minY))

                path.closeSubpath()
            }
        }
    }
}
