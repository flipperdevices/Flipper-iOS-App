import SwiftUI

public struct RootView: View {
    let homeTabTitle = "Home"

    public init() {
    }

    public var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text(self.homeTabTitle)
                }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
