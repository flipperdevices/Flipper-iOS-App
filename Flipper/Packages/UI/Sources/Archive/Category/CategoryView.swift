import SwiftUI

struct CategoryView: View {
    @Environment(\.presentationMode) var presentationMode

    let name: String

    var body: some View {
        Text(name)
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
