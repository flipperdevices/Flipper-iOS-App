import SwiftUI

struct ImportedBanner: View {
    let itemName: String

    var body: some View {
        Banner(
            image: "Done",
            title: itemName,
            description: "saved to Archive"
        )
    }
}
