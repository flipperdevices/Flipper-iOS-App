import Core
import SwiftUI

struct CategoryView: View {
    @Environment(\.presentationMode) var presentationMode

    let name: String
    let items: [ArchiveItem]

    var body: some View {
        ScrollView {
            CategoryList(items: items)
                .padding(14)
        }
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Text(name)
                    .font(.system(size: 20, weight: .bold))
            }
        }
    }
}
