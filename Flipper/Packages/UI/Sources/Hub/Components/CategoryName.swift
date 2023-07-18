import Core
import SwiftUI

struct CategoryName: View {
    let name: String?

    init(_ name: String?) {
        self.name = name
    }

    @Environment(\.colorScheme) var colorScheme

    private var color: Color {
        switch colorScheme {
        case .dark: return .black40
        default: return .black60
        }
    }

    var body: some View {
        Text(name ?? "Unknown")
            .foregroundColor(color)
            .lineLimit(1)
    }
}
