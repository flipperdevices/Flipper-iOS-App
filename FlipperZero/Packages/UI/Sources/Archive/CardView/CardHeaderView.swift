import SwiftUI

struct CardHeaderView: View {
    @Binding var name: String
    let image: Image
    @Binding var isEditMode: Bool
    @Binding var focusedField: String

    let flipped: Bool

    var body: some View {
        HStack {
            if flipped {
                Text(name)
                    .font(.system(size: 22).weight(.bold))
            } else {
                CardTextField(
                    title: "name",
                    text: $name,
                    isEditMode: $isEditMode,
                    focusedField: $focusedField
                )
                .font(.system(size: 22).weight(.bold))
            }

            Spacer()

            image
                .frame(width: 40, height: 40)
        }
    }
}
