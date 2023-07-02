import Core
import SwiftUI

extension AppView {
    struct VersionSize: View {
        let application: Applications.Application

        var length: Int? {
            application.current.build?.asset.length
        }

        var body: some View {
            HStack {
                Column(key: "Version", value: application.current.version)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                Divider()
                    .foregroundColor(.black4)
                Column(key: "Size", value: length?.hr)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
        }

        struct Column: View {
            let key: String
            let value: String?

            var body: some View {
                VStack(spacing: 2) {
                    Text(key)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.black40)
                        .lineLimit(1)

                    if let value = value {
                        Text(value)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                    } else {
                        AnimatedPlaceholder()
                            .frame(width: 30, height: 14)
                    }

                }
            }
        }
    }
}
