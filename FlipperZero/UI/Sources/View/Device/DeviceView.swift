import SwiftUI

public struct DeviceView: View {
    @StateObject var viewModel: DeviceViewModel

    public var body: some View {
        if viewModel.pairedDevice != nil {
            DeviceInfoView(viewModel: .init())
        } else {
            InstructionsView(viewModel: .init())
        }
    }
}

struct DeviceView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceView(viewModel: .init())
    }
}
