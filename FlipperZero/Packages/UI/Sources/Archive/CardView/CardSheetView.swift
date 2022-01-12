import Core
import SwiftUI

struct CardSheetView: View {
    @Environment(\.colorScheme) var colorScheme

    @StateObject var viewModel: ArchiveViewModel

    var sheetBackgroundColor: Color {
        colorScheme == .light
            ? .init(red: 0.95, green: 0.95, blue: 0.97)
            : .init(red: 0.1, green: 0.1, blue: 0.1)
    }

    @State var string = ""
    @State var isEditMode = false
    @State var focusedField = ""

    var isFullScreen: Bool { !focusedField.isEmpty }

    enum Action {
        case delete
        case favorite(Bool)
        case save(ArchiveItem)
    }

    var body: some View {
        VStack {
            if isFullScreen {
                HeaderView(
                    title: viewModel.title,
                    status: viewModel.status,
                    leftView: {
                        Button {
                            viewModel.undoChanges()
                            resignFirstResponder()
                        } label: {
                            Text("Cancel")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(width: 64)
                    },
                    rightView: {
                        Button {
                            viewModel.saveChanges()
                            resignFirstResponder()
                        } label: {
                            Text("Done")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(width: 64)
                    })
                    .padding(.horizontal, 8)
            }

            Spacer(minLength: isFullScreen ? 0 : navigationBarHeight)

            VStack {
                if !isFullScreen {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.gray)
                        .frame(width: 40, height: 6)
                        .padding(.vertical, 18)
                }

                CardView(
                    name: $viewModel.editingItem.name,
                    item: $viewModel.editingItem.value,
                    isEditMode: $isEditMode,
                    focusedField: $focusedField
                )
                .foregroundColor(.white)
                .padding(.top, 5)
                .padding(.horizontal, 16)

                if focusedField.isEmpty {
                    CardActions(viewModel: viewModel, isEditMode: $isEditMode)
                } else {
                    Spacer()
                }
            }
            .background(isFullScreen ? systemBackground : sheetBackgroundColor)
            .cornerRadius(isFullScreen ? 0 : 12)
        }
        // handle keyboard disappear
        .onChange(of: focusedField) {
            if $0.isEmpty {
                viewModel.undoChanges()
            }
        }
    }
}
