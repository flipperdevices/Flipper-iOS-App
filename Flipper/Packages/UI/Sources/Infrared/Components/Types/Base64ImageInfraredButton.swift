import SwiftUI
import Core
import Infrared

struct Base64ImageInfraredButton: View {
    @Environment(\.layoutScaleFactor) private var scaleFactor

    let data: Base64ImageButtonData

    private var imageSize: CGSize {
        .init(width: 24 * scaleFactor, height: 24 * scaleFactor)
    }

    private var uiImage: UIImage? {
        let image = data
            .pngBase64
            .replacing("data:image/png;base64,", with: "")

        guard
            let data = Data(base64Encoded: image),
            let image = UIImage(data: data),
            let scaledImage = image.scaled(to: imageSize)
        else { return nil }

        return scaledImage
    }

    var body: some View {
        InfraredSquareButton {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
            } else {
                EmptyView()
            }
        }
    }
}

private extension UIImage {
    func scaled(to scaledImageSize: CGSize) -> UIImage? {
        let aspectWidth = scaledImageSize.width / self.size.width
        let aspectHeight = scaledImageSize.height / self.size.height
        let aspectRatio = min(aspectWidth, aspectHeight)

        let newSize = CGSize(
            width: self.size.width * aspectRatio,
            height: self.size.height * aspectRatio
        )

        let renderer = UIGraphicsImageRenderer(size: newSize)
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return scaledImage
    }
}
