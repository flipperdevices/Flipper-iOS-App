import SwiftUI

extension FileManagerView.FileManagerListing {
    struct EmptyFolder: View {
        let onUpload: () -> Void

        var body: some View {
            VStack(alignment: .center, spacing: 24) {
                Spacer()

                Text("No Files Yet")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)

                Image("ReportFailed")
                    .renderingMode(.template)
                    .foregroundColor(.primary)

                Text("Upload Files")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.a2)
                    .onTapGesture {
                        onUpload()
                    }

                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}
