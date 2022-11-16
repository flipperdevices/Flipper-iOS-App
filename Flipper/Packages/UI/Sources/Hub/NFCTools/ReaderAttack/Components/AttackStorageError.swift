import SwiftUI
import Peripheral

struct AttackStorageError: View {
    let fliperColor: FlipperColor

    var body: some View {
        VStack(spacing: 18) {
            Text("SD Card is Full or Not Accessible")
                .font(.system(size: 18, weight: .bold))

            Image(
                fliperColor == .white
                    ? "FlipperNoSDCardWhite"
                    : "FlipperNoSDCardBlack"
            )
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(.horizontal, 14)

            Text(
                "Unable to save keys. " +
                "The SD Card is not accessible or there is not enough space"
            )
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.black40)
        }
    }
}
