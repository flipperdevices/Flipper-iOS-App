import Core
import SwiftUI

struct EditInfoView: View {
    let saveChanges: () -> Void
    let undoChanges: () -> Void
    @Binding var current: ArchiveItem
    @Binding var isEditing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CardView(
                item: $current,
                isEditing: $isEditing,
                kind: .existing
            )
            .padding(.top, 6)
            .padding(.horizontal, 24)

            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                CancelButton {
                    undoChanges()
                }
            }

            PrincipalToolbarItems {
                Title("Editing", description: current.name.value)
            }

            TrailingToolbarItems {
                SaveButton {
                    saveChanges()
                }
            }
        }
    }
}
