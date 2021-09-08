import SwiftUI

public struct RootView: View {
    @ObservedObject var viewModel: RootViewModel

    public init(viewModel: RootViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationView {
            TabView {
                DeviceView(viewModel: .init())
                    .tabItem {
                        Image("Device")
                            .renderingMode(.template)
                        Text("Device")
                    }
                ArchiveView(viewModel: .init())
                    .tabItem {
                        Image(systemName: "creditcard.fill")
                        Text("Archive")
                    }
                OptionsView()
                    .tabItem {
                        Image(systemName: "gearshape")
                        Text("Options")
                    }
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(viewModel: .init())
    }
}
