import SwiftUI

struct PartialSheetView: View {
    @EnvironmentObject var sheetManager: SheetManager

    var backgroundColor: Color {
        systemBackground.opacity(sheetManager.isPresented ? 0.5 : 0)
    }

    var animation: Animation {
        .interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0)
    }

    var body: some View {
        ZStack {
            if sheetManager.isPresented {
                Rectangle()
                    .foregroundColor(backgroundColor)
                    .onTapGesture {
                        sheetManager.isPresented = false
                    }
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
