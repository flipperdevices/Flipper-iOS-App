import SwiftUI

struct AppHideBanner: View {
    @Binding var isPresented: Bool
    var undo: () -> Void

    var body: some View {
        Banner(
            image: "Done",
            title: "App is Hidden",
            description: "You won't see this app again"
        ) {
            Button("Undo") {
                isPresented = false
                undo()
            }
        }
    }
}
