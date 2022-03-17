import SwiftUI

struct DeviceInfoRow: View {
    let name: String
    let value: String?

    var body: some View {
        HStack {
            Text("\(name)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black30)
            Spacer()
            Text("\(value ?? .unknown.lowercased())")
                .font(.system(size: 14, weight: .regular))
                .multilineTextAlignment(.trailing)
        }
    }
}
