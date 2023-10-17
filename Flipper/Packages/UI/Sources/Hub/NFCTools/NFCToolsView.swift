import Core
import SwiftUI

struct NFCToolsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var showDetectReaderView = false
    @AppStorage(.hasReaderLog) var hasReaderLog = false

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Button {
                    showDetectReaderView = true
                } label: {
                    DetectReaderCard(hasNotification: hasReaderLog)
                }
            }
            .padding(14)
        }
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
                Title("NFC Tools")
            }
        }
        .fullScreenCover(isPresented: $showDetectReaderView) {
            AlertStack {
                DetectReaderView()
            }
        }
    }
}
