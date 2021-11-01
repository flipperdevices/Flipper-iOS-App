import Core
import Combine
import Injector

public class RootViewModel: ObservableObject {

    // MARK: First Launch

    @Published var presentWelcomeSheet = false

    var isFirstLaunch: Bool {
        get { UserDefaultsStorage.shared.isFirstLaunch }
        set { UserDefaultsStorage.shared.isFirstLaunch = newValue }
    }

    // MARK: Full Application

    @Published var selectedTab: CustomTabView.Tab = .archive
    @Published var isTabViewHidden = false

    public init() {
        presentWelcomeSheet = isFirstLaunch
    }
}
