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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEachIndexed(screenshots) { screenshot, index in
                    AppScreenshot(url: screenshot)
                        .onTapGesture {
                            selectedIndex = index
                        }
                }
            }
            .padding(.horizontal, 14)
        }
        .fullScreenCover(isPresented: isFullScreenMode) {
            if let selectedIndex = selectedIndex {
                FullScreenshotsView(
                    selectedIndex,
                    screenshots: screenshots,
                    title: title
                )
            }
        }
    }
}
