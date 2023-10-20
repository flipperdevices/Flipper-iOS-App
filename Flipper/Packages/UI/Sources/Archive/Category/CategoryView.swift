import Core
import SwiftUI

struct CategoryView: View {
    @EnvironmentObject var archive: ArchiveModel
    @Environment(\.dismiss) private var dismiss

    let kind: ArchiveItem.Kind
    @State private var selectedItem: ArchiveItem?

    var items: [ArchiveItem] {
        archive.items.filter { $0.kind == kind }
    }

    var body: some View {
        ZStack {
            Text("You have no keys yet")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black40)
                .opacity(items.isEmpty ? 1 : 0)

            ScrollView {
                CategoryList(items: items) { item in
                    selectedItem = item
                }
                .padding(14)
            }
        }
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
                Text(kind.name)
                    .font(.system(size: 20, weight: .bold))
            }
        }
        .sheet(item: $selectedItem) { item in
            AlertStack {
                InfoView(item: item)
            }
        }
    }
}
