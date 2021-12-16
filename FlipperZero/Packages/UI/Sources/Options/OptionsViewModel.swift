import Core
import Combine

@MainActor
public class OptionsViewModel: ObservableObject {
    var hideTabbar: (Bool) -> Void = { _ in }

    init(hideTabbar: @escaping (Bool) -> Void = { _ in }) {
        self.hideTabbar = hideTabbar
    }
}
