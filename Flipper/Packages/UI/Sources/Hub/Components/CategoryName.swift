import Core
import SwiftUI
import Foundation
import SVGKit

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
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(color)
            .lineLimit(1)
    }

}
