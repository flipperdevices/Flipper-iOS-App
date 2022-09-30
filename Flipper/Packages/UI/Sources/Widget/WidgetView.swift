import UI
import SwiftUI

public struct WidgetView: View {
    @ObservedObject var viewModel: WidgetViewModel

    public init(viewModel: WidgetViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
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
