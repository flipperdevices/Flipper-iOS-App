import SwiftUI

struct ForEachIndexed<Item, Content: View>: View {
    let items: [Item]
    let content: (Item, Int) -> Content

    init(_ items: [Item], _ content: @escaping (Item, Int) -> Content) {
        self.items = items
        self.content = content
    }

    var body: some View {
        ForEach(
            Array(items.enumerated()),
            id: \.offset
        ) { index, item in
            content(item, index)
        }
    }
}
