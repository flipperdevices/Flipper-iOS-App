import SwiftUI

struct NothingFoundView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image("NothingFound")

            Text("Nothing Found")
                .font(.system(size: 16, weight: .bold))

            Text("There are no files with\nthis name or note")
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.black40)
        }
    }
}
