import SwiftUI

extension NFCEditorView {
    struct SaveChangesAlert: View {
        let viewModel: NFCEditorViewModel

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
                        viewModel.save()
                    } label: {
                        Text("Save")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.a2)
                    }

                    Divider()
                    Button {
                        viewModel.dismiss()
                    } label: {
                        Text("Don't save")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.primary)
                    }

                    Divider()
                    Button {
                        viewModel.saveAs()
                    } label: {
                        Text("Save Dump As...")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}
