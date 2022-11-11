import SwiftUI

struct WidgetError: View {
    let text: String
    let image: String
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 2) {
                Image(image)
                Text(text)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.top, 14)

            HStack {
                Spacer()

                Button {
                    isPresented = false
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 14, weight: .medium))
                        Text("Back")
                            .font(.system(size: 14, weight: .medium))
                    }
                }
                .foregroundColor(.black60)

                Spacer()
                Spacer()

                Button {
                    #if os(iOS)
                    UIApplication.shared.open(.flipperMobile)
                    #endif
                } label: {
                    Text("Open App")
                        .font(.system(size: 14, weight: .medium))
                }

                Spacer()
            }
        }
    }
}
