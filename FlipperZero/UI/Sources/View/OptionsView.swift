import SwiftUI

struct OptionsView: View {
    var body: some View {
        List {
            NavigationLink("Echo server") {
                EchoView(viewModel: .init())
            }
        }
    }
}

struct OptionsView_Previews: PreviewProvider {
    static var previews: some View {
        OptionsView()
    }
}
