import Core
import SwiftUI

extension ReaderAttackView {
    struct CalculatedKeys: View {
        let results: [ReaderAttack.Result]

        var body: some View {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 4) {
                    Text("Calculated Keys")
                        .font(.system(size: 16, weight: .bold))

                    if results.isEmpty {
                        ProgressView()
                    } else {
                        Text("(\(results.count))")
                            .font(.system(size: 16, weight: .medium))
                    }
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(results, id: \.origin.number) { result in
                        HStack(spacing: 0) {
                            Text("Sector \(result.origin.sector)")

                            Text(" — ")

                            Text("Key \(result.origin.keyType.rawValue)")
                                .foregroundColor(result.origin.keyType.color)

                            Text(" — ")

                            if let key = result.key {
                                Text(key.hexValue)
                            } else {
                                Text("Not found")
                            }
                        }
                        .font(.system(size: 12, weight: .medium))
                    }
                }
            }
        }
    }
}
