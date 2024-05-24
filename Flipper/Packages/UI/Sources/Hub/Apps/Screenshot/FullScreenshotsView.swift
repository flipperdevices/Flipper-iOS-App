import Core
import SwiftUI

struct FullScreenshotsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var storage: [Int: UIImage] = [:]
    @State private var currentIndex: Int
    private let screenshots: [URL]
    private let title: String

    init(
        _ currentIndex: Int,
        screenshots: [URL],
        title: String
    ) {
        self.currentIndex = currentIndex
        self.screenshots = screenshots
        self.title = title
    }

    private var currentScreenshot: URL {
        screenshots[currentIndex]
    }

    private var description: String {
        "\(currentIndex + 1)/\(screenshots.count)"
    }

    private var disabledShare: Bool {
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
                },
                trailing: {
                    ShareButton(action: onShare)
                        .disabled(disabledShare)
                        .opacity(disabledShare ? 0.4 : 1)
                }
            )
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEachIndexed(screenshots) { screenshot, _ in
                            ZoomAppScreenshot(
                                currentIndex: currentIndex,
                                url: screenshot,
                                onSwipeRight: onSwipeRight,
                                onSwipeLeft: onSwipeLeft
                            )
                            .frame(width: UIScreen.main.bounds.width)
                        }
                    }
                }
                .scrollDisabled(true)
                .onChange(of: currentIndex) { newIndex in
                    withAnimation {
                        proxy.scrollTo(newIndex, anchor: .center)
                    }
                }
                .onAppear {
                    withAnimation {
                        proxy.scrollTo(currentIndex, anchor: .center)
                    }
                }
            }
            GeometryReader { geometry in
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4.0) {
                            ForEachIndexed(screenshots) { screenshot, index in
                                AppScreenshot(
                                    url: screenshot,
                                    onComplete: { storage[index] = $0 }
                                )
                                .scaleEffect(currentIndex == index ? 1 : 0.8)
                                .onTapGesture { currentIndex = index }
                            }
                        }
                        .frame(height: geometry.size.height)
                        .frame(minWidth: geometry.size.width)
                    }
                    .onChange(of: currentIndex) { newIndex in
                        withAnimation {
                            proxy.scrollTo(newIndex, anchor: .center)
                        }
                    }
                    .onAppear {
                        withAnimation {
                            proxy.scrollTo(currentIndex, anchor: .center)
                        }
                    }
                }
            }
            .frame(height: 64)
            .padding(.bottom, 12)
            .padding(.horizontal, 18)
        }
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

    private func onSwipeRight() {
        if currentIndex < screenshots.count - 1 {
            currentIndex += 1
        }
    }

    private func onSwipeLeft() {
        if currentIndex > 0 {
            currentIndex -= 1
        }
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
