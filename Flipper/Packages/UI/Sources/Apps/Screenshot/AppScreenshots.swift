import Core
import SwiftUI

struct AppScreenshots: View {
    let title: String
    let screenshots: [URL]

    @State private var selectedIndex: Int?
    private var isFullScreenMode: Binding<Bool> {
        Binding<Bool>(
            get: { selectedIndex != nil },
            set: { newValue in
                if !newValue {
                    selectedIndex = nil
                }
            }
        )
    }

    var body: some View {
        AppScreenshotsRaw(
            screenshots: screenshots,
            onTap: { selectedIndex = $0 }
        )
        .fullScreenCover(isPresented: isFullScreenMode) {
            if let selectedIndex = selectedIndex {
                FullScreenshotsView(
                    title: title,
                    screenshots: screenshots,
                    initialIndex: selectedIndex
                )
            }
        }
    }
}

struct AppScreenshotsRaw: View {
    let screenshots: [URL]
    let onTap: (Int) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEachIndexed(screenshots) { screenshot, index in
                    AppScreenshot(url: screenshot)
                        .onTapGesture { onTap(index) }
                }
            }
            .padding(.horizontal, 14)
        }
    }
}

#Preview {
    AppScreenshotsRaw(
        screenshots: [
            .mockValidAppScreenshotFirst,
            .mockUnknownAppScreenshot
        ]
    ) { _ in }
    .frame(height: 150)
}
