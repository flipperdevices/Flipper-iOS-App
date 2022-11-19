import Core
import SwiftUI

extension NFCEditorView {
    struct NFCCard: View {
        @Binding var item: ArchiveItem

        var mifareType: String {
            guard let typeProperty = item.properties.first(
                where: { $0.key == "Mifare Classic type" }
            ) else {
                return "??"
            }
            return typeProperty.value
        }

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
                                Text(item.properties["UID"] ?? "")
                                    .fontWeight(.medium)
                            }

                            HStack(spacing: 23) {
                                HStack {
                                    Text("ATQA:")
                                        .fontWeight(.bold)
                                    Text(item.properties["ATQA"] ?? "")
                                        .fontWeight(.medium)
                                }

                                HStack {
                                    Text("SAK:")
                                        .fontWeight(.bold)
                                    Text(item.properties["SAK"] ?? "")
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
