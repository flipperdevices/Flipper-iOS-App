import Core
import SwiftUI

struct CardActions: View {
    @StateObject var viewModel: ArchiveViewModel
    @Binding var isEditMode: Bool

    var isFavorite: Bool {
        viewModel.editingItem.isFavorite
    }

    var body: some View {
        VStack {
            Divider()

            HStack(alignment: .top) {

                // MARK: Edit

                if isEditMode {
                    Button {
                        isEditMode = false
                    } label: {
                        Image(systemName: "checkmark.circle")
                    }
                    Spacer()
                } else {
                    Button {
                        isEditMode = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }

                    Spacer()

                    // MARK: Share as file

                    Button {
                        share(viewModel.editingItem.value)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }

                    Spacer()

                    // MARK: Favorite

                    Button {
                        viewModel.favorite()
                    } label: {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                    }

                    Spacer()

                    // MARK: Delete

                    Button {
                        viewModel.isDeletePresented = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
            .font(.system(size: 22))
            .foregroundColor(Color.accentColor)
            .padding(.top, 20)
            .padding(.bottom, 45)
            .padding(.horizontal, 22)
        }
    }
}
