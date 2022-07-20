import Combine

class TabViewController: ObservableObject {
    @Published var isHidden = false

    func show() {
        isHidden = false
    }

    func hide() {
        isHidden = true
    }
}
