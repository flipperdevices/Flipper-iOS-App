import SwiftUI

struct Spinner: View {
    var body: some View {
        Animation("Loading")
            .frame(width: 40, height: 40)
            .scaledToFill()
    }
}
