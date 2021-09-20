import Core
import Combine
import Injector

public class RootViewModel: ObservableObject {
    @Published var selectedTab: CustomTabView.Tab = .archive

    public init() {}
}
