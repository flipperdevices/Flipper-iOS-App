import SwiftUI

struct ScrollScreenshots: View {
    let screenshots: [URL]
    @Binding var currentIndex: Int
    let onLoadImage: (UIImage, Int) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEachIndexed(screenshots) { screenshot, _ in
                        ZoomScreenshot(
                            screenshot: screenshot,
                            currentIndex: $currentIndex,
                            onSwipeRight: onSwipeRight,
                            onSwipeLeft: onSwipeLeft
                        )
                        .frame(width: UIScreen.main.bounds.width)
                    }
                }
            }
            // TODO: Remove when fixed
            #if !DEBUG
            .scrollDisabled(true)
            #endif
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
                                onComplete: { onLoadImage($0, index) }
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

#Preview("Start with first screenshot") {
    return ScrollScreenshots(
        screenshots: [
            .mockValidAppScreenshotFirst,
            .mockValidAppScreenshotSecond
        ],
        currentIndex: .constant(0)
    ) { _, _ in }
}

#Preview("Start with second screenshot") {
    return ScrollScreenshots(
        screenshots: [
            .mockValidAppScreenshotFirst,
            .mockUnknownAppScreenshot,
            .mockValidAppScreenshotSecond,
            .mockValidAppScreenshotThird
        ],
        currentIndex: .constant(1)
    ) { _, _ in }
}
