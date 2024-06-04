import SwiftUI

struct ReportedBanner: View {
    let itemName: String
    @Environment(\.colorScheme) var colorScheme

    var backgroundColor: Color {
        colorScheme == .light ? .black4 : .black80
    }

    var body: some View {
        Banner(
            image: "Done",
            title: "Successfully",
            description: "App report has been sent"
        )
    }
}
