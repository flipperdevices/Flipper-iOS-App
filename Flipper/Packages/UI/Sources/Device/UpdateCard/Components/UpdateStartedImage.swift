import SwiftUI

struct UpdateStartedImage: View {
    @Environment(\.colorScheme) var colorScheme

    var image: String {
        colorScheme == .light ? "UpdateStartedLight" : "UpdateStartedDark"
    }

    var body: some View {
        Image(image)
    }
}
