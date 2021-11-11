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
                        Text("Cancel")
                            .font(.system(size: 16))
                    },
                    rightView: {
                        Button {
                        } label: {
                            Text("Done")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    })
            }

            Spacer(minLength: isFullScreen ? 0 : navigationBarHeight)

            VStack {
                if !isFullScreen {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.gray)
                        .frame(width: 40, height: 6)
                        .padding(.vertical, 18)
                }

                Card(
                    item: $viewModel.editingItem,
                    isEditMode: $isEditMode,
                    focusedField: $focusedField
                )
                .foregroundColor(.white)
                .padding(.top, 5)
                .padding(.horizontal, 16)

                if !isEditMode {
                    ActionsForm(actions: viewModel.editingItem.actions) { id in
                        print("action \(id) selected")
                    }
                }

                if focusedField.isEmpty {
                    CardActions(viewModel: viewModel, isEditMode: $isEditMode)
                } else {
                    Spacer()
                }
            }
            .background(isFullScreen ? systemBackground : sheetBackgroundColor)
            .cornerRadius(isFullScreen ? 0 : 12)
        }
    }
}

struct Card: View {
    @Binding var item: ArchiveItem
    @Binding var isEditMode: Bool
    @Binding var focusedField: String

    var gradient: LinearGradient {
        .init(
            colors: [
                item.color,
                item.color2
            ],
            startPoint: .top,
            endPoint: .bottom)
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                CardHeaderView(
                    name: $item.name.value,
                    image: item.icon,
                    isEditMode: $isEditMode,
                    focusedField: $focusedField
                )
                .padding(16)

                CardDivider()

                CardDataView(
                    item: _item,
                    isEditMode: $isEditMode,
                    focusedField: $focusedField
                )
                .padding(16)

                HStack {
                    Spacer()
                    Image(systemName: "checkmark")
                    Spacer()
                }
                .padding(.bottom, 16)
            }
        }
        .background(gradient)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.bottom, 16)
    }
}

struct CardTextField: View {
    let title: String
    @Binding var text: String
    @Binding var isEditMode: Bool
    @Binding var focusedField: String

    var body: some View {
        TextField("", text: $text) { focused in
            focusedField = focused ? title : ""
        }
        .disableAutocorrection(true)
        .disabled(!isEditMode)
        .padding(.horizontal, 5)
        .padding(.vertical, 2)
        .background(Color.white.opacity(isEditMode ? 0.3 : 0))
        .border(Color.white.opacity(focusedField == title ? 1 : 0), width: 2)
        .cornerRadius(4)
    }
}

struct CardHeaderView: View {
    @Binding var name: String
    let image: Image
    @Binding var isEditMode: Bool
    @Binding var focusedField: String

    var body: some View {
        HStack {
            CardTextField(
                title: "name",
                text: $name,
                isEditMode: $isEditMode,
                focusedField: $focusedField
            )
            .font(.system(size: 22).weight(.bold))

            Spacer()

            image
                .frame(width: 40, height: 40)
        }
    }
}

struct CardDivider: View {
    var body: some View {
        Color.white
            .frame(height: 1)
            .opacity(0.3)
    }
}

struct CardDataView: View {
    @Binding var item: ArchiveItem
    @Binding var isEditMode: Bool
    @Binding var focusedField: String

    @State var description: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !item.properties.isEmpty {
                ForEach(item.properties, id: \.key) { item in
                    Text("\(item.key): \(item.value)")
                        .font(.system(size: 20).weight(.semibold))
                }
            }
        }
    }
}

extension ArchiveItem.Action: ActionProtocol {
    var id: String { name }
}

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
                        // isEditMode = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }

                    Spacer()

                    // MARK: Share as file

                    Button {
                        share(viewModel.editingItem, shareOption: .file)
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
