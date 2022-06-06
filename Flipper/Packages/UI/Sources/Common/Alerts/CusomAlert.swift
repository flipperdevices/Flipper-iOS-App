import SwiftUI

extension View {
    func customAlert<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        popup(isPresented: isPresented, hideOnTap: false) {
            ZStack {
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button {
                            withoutAnimation {
                                isPresented.wrappedValue = false
                            }
                        } label: {
                            Image(systemName: "xmark")
                        }
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.primary)
                    }
                    .padding(.top, 19)
                    .padding(.trailing, 19)

                    content()
                        .padding(.horizontal, 12)
                        .padding(.bottom, 12)
                }
                .frame(width: 292)
                .background(RoundedRectangle(cornerRadius: 18)
                    .fill(Color.secondaryGroupedBackground)
                )
            }
            .frame(maxHeight: .infinity)
        }
    }
}
