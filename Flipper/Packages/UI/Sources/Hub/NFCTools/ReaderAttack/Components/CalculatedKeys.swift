import Core
import SwiftUI

extension DetectReaderView {
    struct CalculatedKeys: View {
        let results: [ReaderAttack.Result]
        let showProgress: Bool

        var body: some View {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 4) {
                    Text("Calculated Keys")

                    if showProgress {
                        ProgressView()
                    } else {
                        Text("(\(results.count))")
                    }
                    Spacer()
                }
                .font(.system(size: 14, weight: .bold, design: .monospaced))

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(results, id: \.origin.number) { result in
                        HStack(spacing: 0) {
                            Text("Sector \(result.origin.sector)")

                            Text(" — ")

                            Text("Key \(result.origin.keyType.rawValue)")
                                .foregroundColor(result.origin.keyType.color)

                            Text(" — ")

                            if let key = result.key {
                                Text(key.hexValue.uppercased())
                            } else {
                                Text("Not found")
                                    .foregroundColor(.black30)
                            }
                        }
                    }
                }
                .font(.system(size: 12, weight: .medium, design: .monospaced))
            }
        }
    }
}
