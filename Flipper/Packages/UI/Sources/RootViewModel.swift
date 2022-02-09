import Core
import Combine
import Inject
import Logging
import Foundation

public class RootViewModel: ObservableObject {
    private let logger = Logger(label: "root")

    let appState: AppState = .shared
    let sharing: Sharing = .shared

    @Published var presentWelcomeView = false

    var isFirstLaunch: Bool {
        appState.isFirstLaunch
    }

    public init() {
        presentWelcomeView = isFirstLaunch
    }

    func onOpenURL(_ url: URL) async {
        await sharing.importKey(url)
    }
}
