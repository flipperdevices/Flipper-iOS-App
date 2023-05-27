import SwiftUI

extension ReportBugView {
    struct SubmitView: View {
        var body: some View {
            ZStack {
                VStack(spacing: 14) {
                    Spinner()

                    Text("Uploading report...")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.black60)
                }
            }
        }
    }
}
