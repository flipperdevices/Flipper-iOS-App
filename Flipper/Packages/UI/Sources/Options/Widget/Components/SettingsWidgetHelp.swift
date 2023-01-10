import SwiftUI

typealias ThemedImage = (light: String, dark: String)

struct WidgetHelp: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack {
                SheetHeader(title: "How to Add Widget") {
                    dismiss()
                }

                VStack(alignment: .leading, spacing: 18) {
                    WidgetHelpPoint(
                            text: "1. Swipe right from the left edge of your iPhone`s Home Screen",
                            images: nil
                    )
                    WidgetHelpPoint(
                            text: "2. Scroll down to the bottom and press “Edit”",
                            images: ("WidgetEditLight", "WidgetEditDark")
                    )
                    WidgetHelpPoint(
                            text: "3. Press the “Customize” button at the end of the widget list",
                            images: ("WidgetCustomizeLight", "WidgetCustomizeDark")
                    )
                    WidgetHelpPoint(
                            text: "4. Find the Flipper App, add it to the list of widgets and press “Done”",
                            images: ("WidgetFindLight", "WidgetFindDark")
                    )
                    WidgetHelpPoint(
                            text: "5. Press “Done” in the upper right corner after adding the widget on the screen",
                            images: ("WidgetDoneLight", "WidgetDoneDark")
                    )
                    WidgetHelpPoint(
                            text: "6. Customize your Flipper widget through the widget itself or go to the Widget Settings in Flipper Mobile App",
                            images: ("WidgetAddLight", "WidgetAddDark")
                    )
                }.padding(.horizontal, 14)
            }
        }
    }
}

private struct WidgetHelpPoint: View {
    @Environment(\.colorScheme) private var colorScheme

    let text: String
    let images: ThemedImage?

    var body: some View {

        VStack(alignment: .leading, spacing: 8) {
            Text(text)
                    .font(.system(size: 14, weight: .medium))

            if let images = images {
                let image = colorScheme == .light ? images.light : images.dark
                Image(image)
            }
        }
    }
}
