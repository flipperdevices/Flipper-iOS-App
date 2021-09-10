import SwiftUI

public struct DeviceView: View {
    @StateObject var viewModel: DeviceViewModel

    public var body: some View {
        if let paired = viewModel.pairedDevice {
            DeviceInfoView(viewModel: .init(paired))
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
