import SwiftUI

struct DeviceUpdate: View {
    let update: () -> Void

    var body: some View {
        Card {
            VStack(spacing: 0) {
                HStack {
                    Text("Firmware Update")
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                }
                .padding(.top, 12)
                .padding(.horizontal, 12)

                HStack {
                    Text("Update Channel")
                        .foregroundColor(.black30)
                    Spacer()
                    Text("Dev")
                }
                .font(.system(size: 14))
                .padding(.horizontal, 12)
                .padding(.top, 18)

                Divider()
                    .padding(.top, 12)

                Button {
                    update()
                } label: {
                    HStack {
                        Spacer()
                        Text("UPDATE")
                            .foregroundColor(.white)
                            .font(.custom("Born2bSportyV2", size: 40))
                        Spacer()
                    }
                    .frame(height: 46)
                    .frame(maxWidth: .infinity)
                    .background(Color.sGreenUpdate)
                    .cornerRadius(9)
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                }

                Text("Update Flipper to the latest version")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black16)
                    .padding(.vertical, 24)
            }
        }
    }
}
