import Core
import SwiftUI

struct NFCToolsView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var showDetectReader: Bool
    @AppStorage(.hasReaderLog) var hasReaderLog = false

    init(_ showDetectReader: Binding<Bool>) {
        self._showDetectReader = showDetectReader
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Button {
                    showDetectReader = true
                } label: {
                    DetectReaderCard(hasNotification: hasReaderLog)
                }
            }
            .padding(14)
        }
        .background(Color.background)
        .navigationBarBackground(Color.a1)
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
    }
}
