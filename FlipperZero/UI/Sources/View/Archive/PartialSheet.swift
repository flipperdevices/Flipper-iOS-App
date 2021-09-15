import SwiftUI

struct PartialSheetView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var sheetManager: SheetManager

    var backgroundColor: Color {
        colorScheme == .light ? .white : .black
    }

    var animation: Animation {
        .interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0)
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(backgroundColor.opacity(sheetManager.isPresented ? 0.5 : 0))
                .onTapGesture {
                    sheetManager.isPresented = false
                }

            VStack(spacing: 0) {
                Spacer()
                sheetManager.content
                    .offset(y: sheetManager.offset)
                    .gesture(DragGesture()
                        .onChanged { value in
                            if value.translation.height > 0 {
                                sheetManager.offset = value.translation.height
                            }
                        }
                        .onEnded { _ in
                            if sheetManager.offset > 100 {
                                sheetManager.isPresented = false
                            } else {
                                sheetManager.isPresented = true
                            }
                        })
            }
        }
        .animation(animation)
    }
}

extension View {
    func addPartialSheet() -> some View {
        ZStack {
            self
            PartialSheetView()
        }
    }
}
