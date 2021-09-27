import Core
import Combine
import Injector

public class RootViewModel: ObservableObject {
    @Published var selectedTab: CustomTabView.Tab = .archive
    @Published var isTabViewHidden = false

    public init() {}
}
