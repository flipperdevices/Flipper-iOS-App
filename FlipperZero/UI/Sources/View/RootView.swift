import SwiftUI

public struct RootView: View {
    @ObservedObject var viewModel: RootViewModel

    public init(viewModel: RootViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        if viewModel.pairedDeviceUUID == nil {
            InstructionsView(viewModel: .init())
        } else {
            DeviceInfoView(viewModel: .init())
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(viewModel: .init())
    }
}
