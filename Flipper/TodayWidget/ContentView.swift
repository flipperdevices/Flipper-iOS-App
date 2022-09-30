import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel

    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .foregroundColor(.black4)
            HStack {
                AddKeyView()
                Divider()
                AddKeyView()
            }
            if viewModel.isExpanded {
                Divider()
                    .foregroundColor(.black4)
                HStack {
                    AddKeyView()
                    Divider()
                    AddKeyView()
                }
            }
        }
        .padding(.horizontal, 11)
        .edgesIgnoringSafeArea(.all)
    }
}
