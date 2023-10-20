import SwiftUI

struct AlertStack<Content: View>: View {
    @StateObject var alertController: AlertController = .init()

    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            content()
                .environmentObject(alertController)

            if alertController.isPresented {
                alertController.alert
            }
        }
    }
}
