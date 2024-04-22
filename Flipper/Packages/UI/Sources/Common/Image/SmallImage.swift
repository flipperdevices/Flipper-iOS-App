import SwiftUI

struct SmallImage: View {
    let name: String

    init(_ name: String) {
        self.name = name
    }

    var body: some View {
        Image(name)
            .resizable()
            .renderingMode(.template)
            .frame(width: 24, height: 24)
    }
}
