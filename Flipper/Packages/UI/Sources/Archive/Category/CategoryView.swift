import Core
import SwiftUI

struct CategoryView: View {
    @EnvironmentObject var archive: ArchiveModel
    @Environment(\.dismiss) private var dismiss

    let kind: ArchiveItem.Kind
    @State private var selectedItem: ArchiveItem?
    @State private var showInfoView = false

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
                    showInfoView = true
                }
                .padding(14)
            }
            .navigationDestination(isPresented: $showInfoView) {
                if let selectedItem {
                    InfoView(item: selectedItem)
                }
            }
        }
        .background(Color.background)
        .navigationBarBackground(Color.a1)
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
    }
}
