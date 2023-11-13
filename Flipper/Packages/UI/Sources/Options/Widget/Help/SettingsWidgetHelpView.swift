import SwiftUI

struct SettingsWidgetHelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: "How to Add Widget") {
                dismiss()
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    WidgetHelpPoint(
                        text: "1. Swipe right from the left edge of " +
                            "your iPhone`s Home Screen",
                        image: nil
                    )
                    WidgetHelpPoint(
                        text: "2. Scroll down to the bottom and tap “Edit”",
                        image: "WidgetHelpEdit"
                    )
                    WidgetHelpPoint(
                        text: "3. Tap the “Customize” button at the " +
                            "end of the widget list",
                        image: "WidgetHelpCustomize"
                    )
                    WidgetHelpPoint(
                        text: "4. Find the Flipper App, add it to the " +
                            "list of widgets and tap “Done”",
                        image: "WidgetHelpFind"
                    )
                    WidgetHelpPoint(
                        text: "5. Tap “Done” in the upper right corner " +
                            "after adding the widget on the screen",
                        image: "WidgetHelpDone"
                    )
                    WidgetHelpPoint(
                        text: "6. Customize your Flipper widget through the " +
                            "widget itself or go to the Widget Settings in " +
                            "Flipper Mobile App",
                        image: "WidgetHelpAdd"
                    )
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
            }
        }
    }

    struct WidgetHelpPoint: View {
        let text: String
        let image: String?

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(text)
                    .font(.system(size: 14, weight: .medium))

                if let image = image {
                    Image(image)
                        .resizable()
                        .scaledToFit()
                }
            }
        }
    }
}
