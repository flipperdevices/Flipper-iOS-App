import SwiftUI
import Combine

extension InfraredEditorView {
    struct InfraredEditorItem: View {
        @Binding var text: String
        let onDelete: () -> Void

        var body: some View {
            HStack(spacing: 18) {
                HStack {
                    Image("Swap")
                        .renderingMode(.template)
                        .opacity(0.3)

                    TextField("", text: $text)
                        .font(.born2bSportyV2(size: 23))
                        .frame(maxWidth: .infinity)
                        .submitLabel(.done)
                        .multilineTextAlignment(.center)
                        .autocorrectionDisabled()
                }
                .padding(.horizontal, 12)
                .foregroundColor(.white)
                .frame(height: 48)
                .background(Color.a1)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Image("Delete")
                    .renderingMode(.template)
                    .foregroundColor(.red)
                    .onTapGesture(perform: onDelete)
            }
            .onReceive(Just(text)) { newValue in
                let remoteNameLimit = 21
                let filtered = newValue.prefix(remoteNameLimit)
                guard filtered != newValue else { return }
                text = String(filtered)
            }
        }
    }
}

private extension StringProtocol {
    var allowedCharacters: String {
        #"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"# +
        #"!#\$%&'()-@^_`{}~ "#
    }

    func filtered() -> String {
        .init(filter { allowedCharacters.contains($0) })
    }
}
