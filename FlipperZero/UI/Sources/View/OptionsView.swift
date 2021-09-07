import SwiftUI

struct OptionsView: View {
    var body: some View {
        EchoView(viewModel: .init())
    }
}

struct OptionsView_Previews: PreviewProvider {
    static var previews: some View {
        OptionsView()
    }
}
