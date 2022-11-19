import SwiftUI
import Peripheral

struct AttackStorageError: View {
    let fliperColor: FlipperColor

    var body: some View {
        VStack(spacing: 18) {
            Text("SD Card is Not Accessible")
                .font(.system(size: 18, weight: .bold))

            Image(
                fliperColor == .white
                    ? "FlipperNoSDCardWhite"
                    : "FlipperNoSDCardBlack"
            )
            .resizable()
            .aspectRatio(contentMode: .fit)

            Text(
                "Unable to access reader keys. " +
                "Please verify that SD Card is present and has some space on it"
            )
            .padding(.horizontal, 14)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.black40)
        }
    }
}
