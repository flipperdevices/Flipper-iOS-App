import Core
import SwiftUI

struct FullScreenshotsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var storage: [Int: UIImage] = [:]
    @State private var currentIndex: Int = 0

    let title: String
    let screenshots: [URL]
    let initialIndex: Int

    private var description: String? {
        screenshots.isEmpty ? nil : "\(currentIndex + 1)/\(screenshots.count)"
    }

    private var isShareDisabled: Bool {
        storage[currentIndex] == nil
    }

    var body: some View {
        VStack {
            NavBar(
                leading: {
                    CloseButton {
                        dismiss()
                    }
                },
                principal: {
                    Title(title, description: description)
                        .padding(.horizontal, 44)
                },
                trailing: {
                    ShareButton(action: onShare)
                        .disabled(isShareDisabled)
                        .opacity(isShareDisabled ? 0.4 : 1)
                }
            )
            if screenshots.isEmpty {
                Spacer()
                Text("The screenshots for this app are missing")
                Spacer()
            } else {
                ScrollScreenshots(
                    screenshots: screenshots,
                    currentIndex: $currentIndex
                ) { image, index in
                    storage[index] = image
                }
            }
        }
        .onAppear { currentIndex = initialIndex }
    }

    private func onShare() {
        guard
            let currentImage = storage[currentIndex],
            let resizeImage = currentImage.scaled(by: 4),
            let imageWithBackground = resizeImage.withBackground(color: .a1),
            let data = imageWithBackground.pngData()
        else { return }

        let name = "Screenshot from \(title)"
        UI.shareImage(name: name, data: data)
    }
}

private extension UIImage {
    func scaled(by scaleFactor: CGFloat) -> UIImage? {
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        return scaledImage
    }

    func withBackground(color: Color) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        guard
            let context = UIGraphicsGetCurrentContext(),
            let cgColor = color.cgColor
        else { return nil }

        context.setFillColor(cgColor)
        context.fill(CGRect(origin: .zero, size: size))

        let origin = CGPoint(
            x: (size.width - self.size.width) / 2,
            y: (size.height - self.size.height) / 2
        )
        self.draw(at: origin)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}

#Preview("Screenshots start by first") {
    FullScreenshotsView(
        title: "Some App",
        screenshots: [
            .mockValidAppScreenshotFirst,
            .mockUnknownAppScreenshot,
            .mockValidAppScreenshotSecond,
            .mockValidAppScreenshotThird
        ],
        initialIndex: 0
    )
}

#Preview("Screenshots start by third") {
    FullScreenshotsView(
        title: "Some App",
        screenshots: [
            .mockValidAppScreenshotFirst,
            .mockUnknownAppScreenshot,
            .mockValidAppScreenshotSecond,
            .mockValidAppScreenshotThird
        ],
        initialIndex: 2
    )
}

#Preview("One screenshot") {
    FullScreenshotsView(
        title: "Some App",
        screenshots: [.mockValidAppScreenshotFirst],
        initialIndex: 0
    )
}

#Preview("Empty screenshots") {
    FullScreenshotsView(
        title: "Some App",
        screenshots: [],
        initialIndex: 0
    )
}
