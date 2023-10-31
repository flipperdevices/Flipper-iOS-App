import SwiftUI

struct BottomSheet<Content: View>: View {
    @ViewBuilder var content: () -> Content
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Color.background.opacity(0.001)
                // disable drag gesture over hidden part
                .simultaneousGesture(DragGesture(minimumDistance: 0))
                // replicate hide on tap
                .simultaneousGesture(TapGesture().onEnded { dismiss() })

            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(Color.black60)
                    .frame(width: 36, height: 4)
                    .padding(.vertical, 8)

                content()
            }
            .frame(maxWidth: .infinity)
            .backgroundIfAvailable(.background)
            .cornerRadius(30, corners: [.topLeft, .topRight])
        }
    }
}

extension View {
    func bottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        sheetViewProxy(isPresented: isPresented) {
            BottomSheet {
                content()
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}
