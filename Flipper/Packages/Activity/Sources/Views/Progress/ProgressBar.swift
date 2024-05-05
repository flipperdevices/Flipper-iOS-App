import SwiftUI

// Copied & Adapted from UI

struct ProgressBar: View {
    let color: Color
    let image: String?
    let progress: Double
    let text: String?

    @State private var dots: String = "..."

    private var progressText: String {
        if text == "..." {
            return dots
        }
        return text ?? "\(Int(progress * 100)) %"
    }

    init(color: Color, progress: Double, image: String?, text: String? = nil) {
        self.color = color
        self.progress = progress
        self.image = image
        self.text = text
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 9)
                .stroke(color, lineWidth: 3)

            GeometryReader { reader in
                color.frame(width: reader.size.width * progress)
            }

            HStack {
                if let image = image {
                    Image(image)
                        .padding([.leading, .top, .bottom], 9)
                }

                Spacer()

                Text(progressText)
                    .foregroundColor(.white)
                    .font(.haxrCorpNeue(size: 40))
                    .padding(.bottom, 4)

                Spacer()

                if let image = image {
                    Image(image)
                        .padding([.leading, .top, .bottom], 9)
                        .opacity(0)
                }
            }
        }
        .frame(height: 46)
        .background(color.opacity(0.54))
        .cornerRadius(9)
        .task {
            await animateDots()
        }
    }

    func animateDots() async {
        while !Task.isCancelled {
            try? await Task.sleep(for: .milliseconds(500))
            self.dots = .init(repeating: ".", count: dots.count % 3 + 1)
        }
    }
}
