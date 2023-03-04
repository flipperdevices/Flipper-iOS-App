import SwiftUI
import OrderedCollections

struct DeviceInfoViewCard: View {
    let title: String
    var values: OrderedDictionary<String, String>

    var zippedIndexKey: [(Int, String)] {
        .init(zip(values.keys.indices, values.keys))
    }

    var body: some View {
        Card {
            VStack(spacing: 12) {
                HStack {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                }
                .padding(.bottom, 6)
                .padding(.horizontal, 12)

                ForEach(zippedIndexKey, id: \.0) { index, key in
                    CardRow(name: key, value: values[key] ?? "")
                        .padding(.horizontal, 12)
                    if index + 1 < values.count {
                        Divider()
                    }
                }
            }
            .padding(.vertical, 12)
        }
        .padding(.horizontal, 14)
    }
}
