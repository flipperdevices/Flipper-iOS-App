import SwiftUI

extension FileManagerView.FileManagerEditor {
    struct FileEditorOptions: View {
        @Binding var isPresented: Bool

        let save: () -> Void
        let saveAs: () -> Void

        var body: some View {
            HStack {
                Spacer()
                Card {
                    VStack(alignment: .leading, spacing: 0) {
                        Option(text: "Save") {
                            isPresented = false
                            save()
                        }
                    }
                }
                .frame(width: 150)
            }
            .padding(.horizontal, 14)
            .offset(y: 40)
        }
    }
}

fileprivate extension FileManagerView.FileManagerEditor.FileEditorOptions {
    struct Option: View {
        let text: String
        let onTap: () -> Void

        var body: some View {
            HStack {
                Text(text)
                    .font(.system(size: 16, weight: .medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                Spacer()
            }
            .onTapGesture { onTap() }
        }
    }
}
