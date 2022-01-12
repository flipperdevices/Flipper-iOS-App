import Core
import SwiftUI

struct NFCCardView: View {
    @Binding var item: ArchiveItem
    @Binding var isEditMode: Bool
    @Binding var focusedField: String

    let flipped: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !flipped {
                Text(item.type)

                HStack {
                    Text("UID: \(item.uid)")
                }
                .font(.system(size: 18, weight: .bold))

                HStack {
                    Text("ATQA: \(item.atqa)")
                    Spacer()
                    Text("SAK: \(item.atqa)")
                }
            } else {
                HStack {
                    Text("AID: \(item.aid)")
                    Spacer()
                }
                .opacity(item.aid.isEmpty ? 0 : 1)

                HStack {
                    if !item.name.isEmpty {
                        Text(item.name)
                    }
                    Spacer()
                }

                HStack {
                    if !item.number.isEmpty {
                        Text(item.number)
                            .font(.system(size: 18, weight: .bold))
                    }
                    Spacer()
                }

                HStack {
                    Text("Country code: \(item.countryCode)")
                    Spacer()
                    Text("EXP: \(item.expData)")
                }
                .opacity(item.aid.isEmpty ? 0 : 1)
            }
        }
        .font(.system(size: 16, weight: .medium))
        .padding(.top, 16)
        .padding(.bottom, 4)
        .padding(.horizontal, 16)
    }
}

fileprivate extension ArchiveItem {
    var type: String { self["Device type"] ?? "" }
    var uid: String { self["UID"] ?? "" }
    var atqa: String { self["ATQA"] ?? "" }
    var sak: String { self["SAK"] ?? "" }

    // bank card
    var aid: String { self["AID"] ?? "" }
    var name: String { self["Name"] ?? "" }
    var number: String { self["Number"] ?? "" }
    var expData: String { self["Exp data"] ?? "" }
    var countryCode: String { self["Country code"] ?? "" }
}
