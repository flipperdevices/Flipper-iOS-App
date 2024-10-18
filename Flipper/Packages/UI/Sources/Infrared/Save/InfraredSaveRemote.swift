import Core
import SwiftUI

extension InfraredView {
    struct InfraredSaveRemote: View {
        @AppStorage(.selectedTab) var selectedTab: TabView.Tab = .device

        @EnvironmentObject private var archive: ArchiveModel
        @EnvironmentObject private var infrared: InfraredModel

        @Environment(\.dismiss) private var dismiss
        @Environment(\.path) private var path

        @State private var currentItem: ArchiveItem = .none
        @State private var error: String?

        let file: InfraredFile
        let item: ArchiveItem

        var body: some View {
            VStack(spacing: 0) {
                CardView(
                    item: $currentItem,
                    isEditing: .constant(true),
                    kind: .imported
                )
                .padding(.top, 18)
                .padding(.horizontal, 24)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                LeadingToolbarItems {
                    CancelButton {
                        dismiss()
                    }
                }
                PrincipalToolbarItems {
                    Title(file.name, description: "Rename")
                }
                TrailingToolbarItems {
                    HStack {
                        SaveButton {
                            save()
                        }
                        .disabled(currentItem.name.value.isEmpty)
                    }
                }
            }
            .onAppear {
                currentItem = item
            }
            .alert(item: $error) { error in
                Alert(title: Text(error))
            }
        }

        private func save() {
            Task {
                do {
                    if archive.isExist(currentItem) {
                        // TODO: remove dependency
                        throw Archive.Error.alreadyExists
                    }

                    try await infrared.copyTemp(currentItem)
                    try await archive.add(currentItem, open: true)
                    path.clear()
                    recordInfraredLibrarySave()
                } catch {
                    self.error = String(describing: error)
                }
            }
        }

        // MARK: Analytics

        private func recordInfraredLibrarySave() {
            analytics.appOpen(target: .infraredLibrarySave)
        }
    }
}
