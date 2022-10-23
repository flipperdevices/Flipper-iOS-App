import SwiftUI

struct ProgressBarView: View {
    let image: String
    let text: String
    let color: Color
    let progress: Double

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 9)
                .stroke(color, lineWidth: 3)

            GeometryReader { reader in
                color.frame(width: reader.size.width * progress)
            }

            HStack {
                Image(image)
                    .padding([.leading, .top, .bottom], 9)

                Spacer()

                Text(text)
                    .foregroundColor(.white)
                    .font(.haxrCorpNeue(size: 40))
                    .padding(.bottom, 4)

                Spacer()

                Image(image)
                    .padding([.leading, .top, .bottom], 9)
                    .opacity(0)
            }
        }
        .frame(height: 46)
        .background(color.opacity(0.54))
        .cornerRadius(9)
    }
}
