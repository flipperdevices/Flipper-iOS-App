import SwiftUI

struct LowBatteryAlert: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 0) {
            Image("LowBattery")
                .padding(.top, 8)

            Text("Low Battery on Flipper")
                .font(.system(size: 14, weight: .bold))
                .padding(.top, 24)

            Text("Charge Flipper to 10% before installing the update")
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.black40)
                .padding(.horizontal, 12)
                .padding(.top, 4)

            Button {
                withoutAnimation {
                    presentationMode.wrappedValue.dismiss()
                }
            } label: {
                Text("Got It")
                    .frame(height: 41)
                    .frame(maxWidth: .infinity)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .background(Color.a2)
                    .cornerRadius(30)
            }
            .padding(.top, 23)
        }
        .padding(.top, 13)
    }
}
