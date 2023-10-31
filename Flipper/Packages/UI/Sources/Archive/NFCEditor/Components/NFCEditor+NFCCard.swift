import Core
import SwiftUI

extension NFCEditorView {
    struct NFCCard: View {
        var mifareType: String
        var uid: [UInt8]
        var atqa: [UInt8]
        var sak: [UInt8]

        var body: some View {
            Image("NFCCard")
                .resizable()
                .scaledToFit()
                .overlay(
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 4) {
                            Text("MIFARE Classic \(mifareType)")
                                .font(.system(size: 12, weight: .heavy))

                            Image("NFCCardWaves")
                                .frame(width: 24, height: 24)
                        }

                        Spacer()

                        Image("NFCCardInfo")
                            .resizable()
                            .scaledToFit()

                        Spacer()

                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text("UID:")
                                    .fontWeight(.bold)
                                Text(uid.hexString)
                                    .fontWeight(.medium)
                            }

                            HStack(spacing: 23) {
                                HStack {
                                    Text("ATQA:")
                                        .fontWeight(.bold)
                                    Text(atqa.hexString)
                                        .fontWeight(.medium)
                                }

                                HStack {
                                    Text("SAK:")
                                        .fontWeight(.bold)
                                    Text(sak.hexString)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                        .font(.system(size: 10))
                    }
                    .padding(14)
                    .foregroundColor(.white)
                )
        }
    }
}

private extension Array where Element == UInt8 {
    var hexString: String {
        self
            .map {
                String(format: "%02X", $0)
            }
            .joined(separator: " ")
            .uppercased()
    }
}
