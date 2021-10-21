import Core
import SwiftUI

struct CardSheetView: View {
    @Environment(\.colorScheme) var colorScheme
    let device: Peripheral?
    @Binding var item: ArchiveItem

    var sheetBackgroundColor: Color {
        colorScheme == .light
            ? .init(red: 0.95, green: 0.95, blue: 0.97)
            : .init(red: 0.1, green: 0.1, blue: 0.1)
    }

    @State var string = ""
    @State var isEditMode = false
    @State var focusedField = ""

    var isFullScreen: Bool { !focusedField.isEmpty }

    var body: some View {
        VStack {
            if isFullScreen {
                HeaderView(
                    title: device?.name ?? "No device",
                    status: .init(device?.state),
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
                    item: $item,
                    isEditMode: $isEditMode,
                    focusedField: $focusedField
                )
                .foregroundColor(.white)
                .padding(.top, 5)
                .padding(.horizontal, 16)

                if !isEditMode {
                    CardDeviceActions(item: item)
                }

                if focusedField.isEmpty {
                    CardActions(item: item, isEditMode: $isEditMode)
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
                    name: $item.name,
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
            if !item.description.isEmpty {
                CardTextField(
                    title: "description",
                    text: $item.description,
                    isEditMode: $isEditMode,
                    focusedField: $focusedField
                )
                .font(.system(size: 20).weight(.semibold))
            }

            if !item.origin.isEmpty {
                HStack {
                    CardTextField(
                        title: "origin",
                        text: $item.origin,
                        isEditMode: $isEditMode,
                        focusedField: $focusedField
                    )
                    .font(.system(size: 20).weight(.semibold))
                    Spacer()
                    Text(String(item.origin.reversed()))
                }
            }
        }
    }
}

struct CardDeviceActions: View {
    let item: ArchiveItem

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(zip(item.actions.indices, item.actions)), id: \.0) { item in
                if item.0 > 0 {
                    Divider()
                        .padding(0)
                }
                CardDeviceAction(action: item.1)
            }
        }
        .background(systemBackground)
        .foregroundColor(Color.accentColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

struct CardDeviceAction: View {
    let action: ArchiveItem.Action

    var body: some View {
        HStack {
            Text(action.name)
                .font(.system(size: 16))
            Spacer()
            action.icon
                .font(.system(size: 22))
        }
        .padding(16)
    }
}

struct CardActions: View {
    let item: ArchiveItem
    @Binding var isEditMode: Bool

    @State var isSharePresented = false
    @State var isFavorite = false
    @State var isDeletePresented = false

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

                    // MARK: Share

                    Button {
                        share([item.name])
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }

                    Spacer()

                    // MARK: Favorite

                    Button {
                        isFavorite.toggle()
                    } label: {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                    }

                    Spacer()

                    // MARK: Delete

                    Button {
                        isDeletePresented = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .actionSheet(isPresented: $isDeletePresented) {
                        .init(
                            title: Text("You can't undo this action"),
                            buttons: [
                                .destructive(Text("Delete")) {
                                    print("delete")
                                },
                                .cancel()
                            ]
                        )
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
