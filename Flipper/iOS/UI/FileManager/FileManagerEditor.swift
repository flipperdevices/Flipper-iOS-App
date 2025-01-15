import Core
import Peripheral

import SwiftUI

extension FileManagerView {
    struct FileManagerEditor: View {
        let path: Peripheral.Path

        @EnvironmentObject var fileManager: RemoteFileManager

        @Environment(\.dismiss) var dismiss
        @Environment(\.popups) var popups

        @State private var current: String = ""
        @State private var backup: String = ""

        @State private var error: String?
        @State private var isLoading = false

        @State private var showSaveChanges = false
        @State private var showOptions = false

        @FocusState private var textFieldFocus: Bool

        var body: some View {
            VStack {
                if let error = error {
                    Text(error)
                } else if isLoading {
                    ProgressView()
                } else {
                    TextEditor(text: $current)
                        .focused($textFieldFocus)
                        .font(.system(size: 14, weight: .medium))
                        .hideScrollBackground()
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .navigationBarBackground(Color.a1)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                LeadingToolbarItems {
                    BackButton {
                        textFieldFocus = false
                        back()
                    }
                }
                PrincipalToolbarItems(alignment: .leading) {
                    Title(path.lastComponent ?? "")
                }
                TrailingToolbarItems {
                    SaveButton {
                        textFieldFocus = false
                        save()
                    }
                    .disabled(isLoading || error != nil)
                }
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Text("Done")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.a1)
                            .onTapGesture { textFieldFocus = false }
                    }
                }
            }
            .alert(isPresented: $showSaveChanges) {
                SaveChangesContentAlert(
                    isPresented: $showSaveChanges,
                    save: save,
                    saveAs: saveAs,
                    dontSave: dontSave
                )
            }
            .popup(isPresented: $showOptions) {
                FileEditorOptions(
                    isPresented: $showOptions,
                    save: save,
                    saveAs: saveAs
                )
            }
            .task { await load() }
        }

        private func load() async {
            isLoading = true
            defer { isLoading = false }

            do {
                current = try await fileManager.readFile(at: path)
                backup = current
            } catch {
                self.error = String(describing: error)
            }
        }

        private func back() {
            if current != backup {
                showSaveChanges = true
            } else {
                dismiss()
            }
        }

        private func save() {
            Task {
                isLoading = true
                defer { isLoading = false }

                do {
                    try await fileManager.writeFile(current, at: path)
                    dismiss()
                } catch {
                    self.error = String(describing: error)
                }
            }
        }

        // TODO
        private func saveAs() {}

        private func dontSave() {
            dismiss()
        }
    }
}
