import SwiftUI
import Peripheral

struct ReaderDataNotFound: View {
    let flipperColor: FlipperColor

    var instructions: [AttributedString] = {
        [
            "On your Flipper Zero, go to **NFC → Extract MF Keys**",
            "Hold Flipper Zero close to the reader",
            "Wait until you collect enough nonсes",
            "Сomplete nonce collection",
            "In Flipper Mobile App, synchronize with your Flipper " +
            "Zero and run the **Mfkey32 (Extract MF Keys)**"
        ]
        .compactMap {
            try? .init(
                markdown: $0,
                options: .init(
                    allowsExtendedAttributes: true,
                    interpretedSyntax: .full))
        }
    }()

    var body: some View {
        VStack(spacing: 18) {
            Text("Reader Data Not Found")
                .font(.system(size: 18, weight: .bold))

            VStack(spacing: 34) {
                FlipperDetectReaderImage()
                    .flipperColor(flipperColor)
                    .padding(.leading, 10)
                    .padding(.trailing, 22)

                VStack(alignment: .leading, spacing: 12) {
                    Text(
                        "To extract keys from the reader, collect nonces " +
                        "with your Flipper Zero first:"
                    )
                    .font(.system(size: 16, weight: .medium))

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(instructions.indices, id: \.self) { index in
                            HStack(alignment: .top, spacing: 0) {
                                Text("\(index + 1). ")
                                Text(instructions[index])
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .font(.system(size: 16))
                        .opacity(0.5)
                    }
                }
            }
        }
    }
}
