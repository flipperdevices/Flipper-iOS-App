import SwiftUI

extension InfraredEditorView {
    struct SaveChangesAlert: View {
        @Binding var isPresented: Bool
        let save: () -> Void
        let dontSave: () -> Void

        var body: some View {
            VStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("Save Changes?")
                        .font(.system(size: 14, weight: .bold))
                        .padding(.top, 5)

                    Text("All unsaved changes will be lost")
                        .font(.system(size: 14, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black40)
                        .padding(.horizontal, 12)
                }

                VStack(spacing: 14) {
                    Divider()
                    Button {
                        isPresented = false
                        save()
                    } label: {
                        Text("Save")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.a2)
                    }

                    Divider()
                    Button {
                        isPresented = false
                        dontSave()
                    } label: {
                        Text("Don't save")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}
