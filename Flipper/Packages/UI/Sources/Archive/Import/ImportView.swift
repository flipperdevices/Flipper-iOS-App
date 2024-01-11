import Core
import SwiftUI

struct ImportView: View {
    @EnvironmentObject var device: Device
    @EnvironmentObject var archive: ArchiveModel
    @Environment(\.dismiss) private var dismiss

    let url: URL

    @State private var state: ImportState = .loading

    @State private var item: ArchiveItem = .none
    @State private var backup: ArchiveItem = .none

    @State private var isEditing = false
    @State private var error: String?

    enum ImportState {
        case loading
        case loaded
        case error(Error)
    }

    enum Error: String {
        case noInternet
        case cantConnect
        case invalidFile
        case expiredLink
    }

    init(url: URL) {
        self.url = url
    }

    var body: some View {
        Group {
            switch state {
            case .loading:
                ScrollView {
                    VStack(spacing: 18) {
                        CardPlaceholder()

                        AnimatedPlaceholder()
                            .frame(maxWidth: .infinity)
                            .frame(height: 41)
                            .cornerRadius(30)
                    }
                    .padding(.top, 6)
                    .padding(.horizontal, 24)
                }
            case .error(.noInternet):
                VStack {
                    Spacer()
                    NoInternetError {
                        retry()
                    }
                    Spacer()
                }
            case .error(.cantConnect):
                VStack {
                    Spacer()
                    CantConnectError {
                        retry()
                    }
                    Spacer()
                }
            case .error(.invalidFile):
                VStack {
                    Spacer()
                    InvalidFileError()
                    Spacer()
                }
            case .error(.expiredLink):
                VStack {
                    Spacer()
                    ExpiredLinkError()
                    Spacer()
                }
            case .loaded:
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        CardView(
                            item: $item,
                            isEditing: $isEditing,
                            kind: .imported
                        )
                        .padding(.top, 6)
                        .padding(.horizontal, 24)

                        Button {
                            add()
                        } label: {
                            Text("Save to Archive")
                                .roundedButtonStyle(maxWidth: .infinity)
                        }
                        .padding(.top, 18)
                        .padding(.horizontal, 24)
                        .opacity(isEditing ? 0 : 1)

                        Spacer()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                if isEditing {
                    NavBarButton {
                        undoChanges()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 8)
                    }
                } else {
                    BackButton {
                        dismiss()
                    }
                }
            }

            PrincipalToolbarItems {
                Title(
                    isEditing ? "Edit Key" : "Add Key",
                    description: item.name.value
                )
            }

            TrailingToolbarItems {
                if isEditing {
                    NavBarButton {
                        saveChanges()
                    } label: {
                        Text("Save")
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 8)
                    }
                }
            }
        }
        .alert(item: $error) { error in
            Alert(title: Text(error))
        }
        .background(Color.background)
        .edgesIgnoringSafeArea(.bottom)
        .task {
            await loadItem()
        }
    }

    func loadItem() async {
        self.state = .loading
        do {
            self.item = try await archive.loadItem(url: url)
            self.state = .loaded
        } catch let error as URLError {
            switch error.code {
            case .dataNotAllowed: state = .error(.noInternet)
            case .fileDoesNotExist: state = .error(.expiredLink)
            default: state = .error(.cantConnect)
            }
        } catch {
            self.state = .error(.invalidFile)
        }
    }

    func retry() {
        Task { @MainActor in
            await loadItem()
        }
    }

    func add() {
        Task { @MainActor in
            do {
                try await archive.add(item)
                dismiss()
            } catch {
                showError(error)
            }
        }
    }

    func edit() {
        withAnimation {
            isEditing = true
        }
    }

    func saveChanges() {
        backup = item
        withAnimation {
            isEditing = false
        }
    }

    func undoChanges() {
        item = backup
        withAnimation {
            isEditing = false
        }
    }

    func showError(_ error: Swift.Error) {
        self.error = String(describing: error)
    }
}

extension ArchiveItem {
    static var none: Self {
        .init(
            name: "",
            kind: .ibutton,
            properties: [],
            shadowCopy: [])
    }
}

// FIXME: Use Identifiable Error
extension String: Identifiable {
    public var id: Self { self }
}
